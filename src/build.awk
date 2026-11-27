#!/usr/bin/awk -f
# build.awk - Generate install/update/remove scripts from CSV data
#
# Concepts:
#   ingest: capabilities (usable sources) + source registry (order, commands)
#           + packages (the data model)
#   emit:   three scripts, three shapes:
#     install -> per package, guard || command
#     update  -> per source,  command || report-failure
#     clean   -> per package, guard && command
# Every emitted line is runnable on its own; failures are visible, not silent.

BEGIN {
    FS = ","

    output_dir = ENVIRON["OUTPUT_DIR"]
    if (output_dir == "") {
        output_dir = "."
    }

    home = ENVIRON["HOME"]
    if (home == "") {
        home = "/home/plagache"
    }

    target_level = 0     # default, overridden by capabilities metadata
    dotfiles_dir = ""    # filled by the git dotfiles package, needed by ln rows
    q = "\""
}

# Substitute CSV template variables.
function substitute(text, name, directory, url, dotfiles) {
    gsub(/%name/, name, text)
    gsub(/%dir/, directory, text)
    gsub(/%url/, url, text)
    gsub(/%dotfiles/, dotfiles, text)
    gsub(/\$HOME/, home, text)
    return text
}

# Write the common script header. detail completes the banner.
function open_script(file, detail) {
    printf "#!/bin/sh\n\n" > file
    printf "# This file was automatically generated with\n" >> file
    printf "# Level: %d\n", target_level >> file
    if (detail == "") {
        printf "\n### From {%d} sources\n", ordered_count >> file
    } else {
        printf "\n### From {%d} sources %s\n", ordered_count, detail >> file
    }
    printf "\nset -e\n" >> file
}

function section(file, src) {
    printf "\n###----------[ %s ]----------###\n", src >> file
}

# Emit sources in canonical order: declared order first, undeclared last.
function ordered_sources(    src, p) {
    ordered_count = 0
    for (p = 1; p <= 98; p++) {
        for (src in source_packages) {
            if (source_priority[src] == p) {
                ordered_list[++ordered_count] = src
            }
        }
    }
    for (src in source_packages) {
        if (source_priority[src] == "" || source_priority[src] >= 99) {
            ordered_list[++ordered_count] = src
        }
    }
}

# install_system: one guard || command line per package
function write_install_script(    file, src, s, i, n, name, pkg_key,
                                  directory, url, install_cmd, present_cmd,
                                  pkg_arr, parts, pkg_dir, subdir,
                                  ln_target, ln_source) {
    file = output_dir "/install_system"
    open_script(file, sprintf("{%d} packages to install", total_packages))

    for (s = 1; s <= ordered_count; s++) {
        src = ordered_list[s]
        section(file, src)

        n = split(source_packages[src], pkg_arr, "|")
        for (i = 1; i <= n; i++) {
            name = pkg_arr[i]
            if (name == "") continue

            pkg_key = src "_" name
            directory = packages[pkg_key, "directory"]
            url = packages[pkg_key, "url"]

            install_cmd = commands[src, "install"]
            present_cmd = commands[src, "present"]

            if (src == "ln") {
                if (name ~ /\//) {
                    # Has subdirectory: "zsh/.zshenv"
                    split(name, parts, "/")
                    pkg_dir = parts[1]
                    subdir = parts[2]
                    ln_target = home "/" subdir
                    ln_source = home "/" dotfiles_dir "/" pkg_dir "/" subdir
                } else {
                    # No subdirectory: "zsh" -> .config/zsh
                    ln_target = home "/.config/" name
                    ln_source = home "/" dotfiles_dir "/" name "/.config/" name
                }
                install_cmd = "ln -sf " q ln_source q " " q ln_target q
            } else {
                install_cmd = substitute(install_cmd, name, directory, url, dotfiles_dir)
            }

            present_cmd = substitute(present_cmd, name, directory, url, dotfiles_dir)

            if (present_cmd != "") {
                printf "%s || %s\n", present_cmd, install_cmd >> file
            } else {
                printf "%s\n", install_cmd >> file
            }
        }
    }

    printf "\n### End of %s/install_system ###\n", output_dir >> file
    close(file)
}

# update_system: one source-level step per line, each reporting its own failure
function write_update_script(    file, src, s, a, actions, action, cmd) {
    file = output_dir "/update_system"
    open_script(file, "")

    for (s = 1; s <= ordered_count; s++) {
        src = ordered_list[s]

        # Sources with no update/upgrade/clean at all (git, curl, ln, ...)
        # produce no block; this is a data fact, not a hardcoded list.
        if (commands[src, "update"] == "" &&
            commands[src, "upgrade"] == "" &&
            commands[src, "clean"] == "") {
            continue
        }

        section(file, src)

        split("update upgrade clean", actions, " ")
        for (a = 1; a <= 3; a++) {
            action = actions[a]
            cmd = commands[src, action]
            if (cmd == "") continue

            cmd = substitute(cmd, "", "", "", dotfiles_dir)
            printf "%s || printf '✗ failed: %s %s\\n' >&2\n", cmd, src, action >> file
        }
    }

    printf "\n### don't forget to add a cronjob\n" >> file
    printf "#@reboot        root    $HOME/.multi_to0l/unix/user/update_user\n" >> file
    close(file)
}

# clean_system: one guard && command line per package
function write_clean_script(    file, src, s, i, n, name, pkg_key,
                                directory, pkg_arr, remove_cmd, remove_guard) {
    file = output_dir "/clean_system"
    open_script(file, "{0} packages to remove")

    for (s = 1; s <= ordered_count; s++) {
        src = ordered_list[s]

        if (commands[src, "remove"] == "") {
            printf "\n# %s - no remove command available\n", src >> file
            continue
        }

        section(file, src)

        n = split(source_packages[src], pkg_arr, "|")
        for (i = 1; i <= n; i++) {
            name = pkg_arr[i]
            if (name == "") continue

            pkg_key = src "_" name
            directory = packages[pkg_key, "directory"]

            remove_cmd = substitute(commands[src, "remove"], name, directory, "", dotfiles_dir)
            remove_guard = substitute(commands[src, "remove_guard"], name, directory, "", dotfiles_dir)

            if (remove_guard != "") {
                printf "%s && %s\n", remove_guard, remove_cmd >> file
            } else {
                printf "%s\n", remove_cmd >> file
            }
        }
    }

    printf "\n### End of %s/clean_system ###\n", output_dir >> file
    close(file)
}

# Read capabilities file
# Format: source OR metadata: level,N / root,yes / ssh,yes
FILENAME ~ /capabilities/ {
    if ($1 == "level") {
        target_level = $2 + 0
        next
    }
    if ($1 == "root" || $1 == "ssh") {
        next
    }
    if ($1 == "" || $1 == "source") next

    usable_sources[$1] = 1
    next
}

# Read source registry - has header
# Format: source,order,detect_cmd,update_cmd,upgrade_pkgm,clean_pkgm,install_cmd,remove_cmd,present_cmd,remove_guard
# (detect_cmd is consumed by detect_environment; build.awk only needs order + commands)
FILENAME ~ /source_commands/ {
    if (FNR == 1) next
    if ($1 == "" || $1 == "source" || $1 ~ /^#/) next

    src = $1
    source_priority[src] = $2 + 0
    commands[src, "update"] = $4
    commands[src, "upgrade"] = $5
    commands[src, "clean"] = $6
    commands[src, "install"] = $7
    commands[src, "remove"] = $8
    commands[src, "present"] = $9
    commands[src, "remove_guard"] = $10
    next
}

# Process packages.csv format:
# source,name,level,directory,url,description
#
# Note: ln rows need dotfiles_dir, set by the git dotfiles row. packages.csv
# declares the git rows first; the ingest order is load-bearing.
FILENAME ~ /packages/ && !($1 == "" || $1 == "source" || $1 ~ /^#/) {
    src = $1
    name = $2
    level = $3 + 0
    directory = $4
    url = $5

    # Skip archived (999) and above-plan-level packages
    if (level == 999 || level > target_level) next

    # Legacy stow rows emit ln lines
    if (src == "stow") {
        src = "ln"
    }

    # Track dotfiles directory from the git repo (ln packages reference it)
    if (src == "git" && (name == "dotfiles" || name == "dot_files")) {
        dotfiles_dir = directory
    }

    # Only keep packages whose source is available on this system
    if (!usable_sources[src]) next

    source_pkg_count[src]++
    if (!(src in source_packages)) {
        source_packages[src] = name
    } else {
        source_packages[src] = source_packages[src] "|" name
    }

    pkg_key = src "_" name
    packages[pkg_key, "directory"] = directory
    packages[pkg_key, "url"] = url

    total_packages++
}

END {
    if (total_packages == 0) {
        print "No packages to install"
        exit 1
    }

    ordered_sources()

    write_install_script()
    write_update_script()
    write_clean_script()

    printf "Generated profile (level %d) with %d sources and %d packages:\n", target_level, ordered_count, total_packages
    for (s = 1; s <= ordered_count; s++) {
        src = ordered_list[s]
        if (src in source_pkg_count) {
            printf "  - %s: %d packages\n", src, source_pkg_count[src]
        }
    }
}
