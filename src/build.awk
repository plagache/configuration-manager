#!/usr/bin/awk -f
# build.awk - Generate install/update/remove scripts
# Groups by source, uses ln instead of stow, update per source

BEGIN {
    FS = ","
    OFS = ","
    
    # Get output directory from environment
    output_dir = ENVIRON["OUTPUT_DIR"]
    if (output_dir == "") {
        output_dir = "."
    }
    
    # Get HOME from environment
    home = ENVIRON["HOME"]
    if (home == "") {
        home = "/home/plagache"
    }
    
    # Source priority order for sorting
    # System package managers first, then user, then git/curl, then ln
    source_order["pacman"] = 1
    source_order["apt"] = 2
    source_order["paru"] = 3
    source_order["yay"] = 4
    source_order["brew"] = 5
    source_order["nix"] = 6
    source_order["git"] = 7
    source_order["curl"] = 8
    source_order["ln"] = 9
    
    # Default level filter (0 = base)
    target_level = 0
    
    # Track dotfiles directory from git repo
    dotfiles_dir = ""
}

# Read capabilities file
# Format: source OR metadata: level,N / root,yes / ssh,yes
FILENAME ~ /capabilities/ {
    # Skip metadata lines
    if ($1 == "level") {
        target_level = $2 + 0
        next
    }
    if ($1 == "root" || $1 == "ssh") {
        next
    }
    if ($1 == "" || $1 == "source") next
    
    # This is a source capability line
    usable_sources[$1] = 1
    
    # Track unique sources
    if (!($1 in unique_sources)) {
        unique_sources[$1] = 1
        source_list[++source_count] = $1
    }
    next
}

# Read source commands file - has header
# Format: source,update_cmd,upgrade_pkgm,clean_pkgm,install_cmd,remove_cmd
FILENAME ~ /source_commands/ {
    if (FNR == 1) next  # Skip header
    if ($1 == "" || $1 == "source") next
    if ($1 ~ /^#/) next  # Skip comments
    src = $1
    commands[src, "update"] = $2
    commands[src, "upgrade"] = $3
    commands[src, "clean"] = $4
    commands[src, "install"] = $5
    commands[src, "remove"] = $6
    next
}

# Process packages_v2.csv format:
# source,name,level,directory,url,description
FILENAME ~ /packages/ && !($1 == "" || $1 == "source" || $1 ~ /^#/) {
    source = $1
    name = $2
    level = $3 + 0  # Convert to number
    directory = $4
    url = $5
    description = $6
    
    # Skip archived packages (level 999)
    if (level == 999) next
    
    # Filter by level (only include packages <= target level)
    if (level > target_level) next
    
    # Convert stow to ln for dotfiles
    if (source == "stow") {
        source = "ln"
    }
    
    # Track dotfiles git repo directory for ln packages
    if (source == "git" && (name == "dotfiles" || name == "dot_files")) {
        dotfiles_dir = directory
    }
    
    # Store the original directory before any modification
    original_directory = directory
    
    # For ln packages, source is dotfiles_dir/name, target is original directory
    # The substitution will use %dir for target and %dotfiles for source
    
    # Check if this source is available on this system
    if (!usable_sources[source]) next
    
    # Track packages per source
    source_pkg_count[source]++
    if (!(source in source_packages)) {
        source_packages[source] = name
    } else {
        source_packages[source] = source_packages[source] "|" name
    }
    
    # Store package details
    pkg_key = source "_" name
    packages[pkg_key, "name"] = name
    packages[pkg_key, "directory"] = original_directory
    packages[pkg_key, "url"] = url
    packages[pkg_key, "source"] = source
    packages[pkg_key, "level"] = level
    
    total_packages++
}

END {
    if (total_packages == 0) {
        print "No packages to install"
        exit 1
    }
    
    # Sort sources by priority order
    sorted_count = 0
    for (src in source_packages) {
        prio = source_order[src]
        if (prio == 0) prio = 99
        if (!(prio in sorted_sources)) {
            sorted_sources[prio] = src
            sorted_list[++sorted_count] = prio
        }
    }
    # Sort priorities
    n = sorted_count
    for (i = 1; i <= n; i++) {
        for (j = i + 1; j <= n; j++) {
            if (sorted_list[i] > sorted_list[j]) {
                tmp = sorted_list[i]
                sorted_list[i] = sorted_list[j]
                sorted_list[j] = tmp
            }
        }
    }
    # Rebuild source_list in sorted order
    delete sorted_source_list
    for (i = 1; i <= sorted_count; i++) {
        prio = sorted_list[i]
        src = sorted_sources[prio]
        if (src != "" && (src in source_packages)) {
            sorted_source_list[++source_count_sorted] = src
        }
    }
    
    # ========== GENERATE INSTALL SCRIPT ==========
    install_file = output_dir "/install_system"
    printf "#!/usr/bin/env bash\n\n" > install_file
    printf "# This file was automatically generated with\n" >> install_file
    printf "# Level: %d\n", target_level >> install_file
    printf "\n### From {%d} sources {%d} packages to install\n\n", source_count_sorted, total_packages >> install_file
    
    # Group by source
    for (s = 1; s <= source_count_sorted; s++) {
        src = sorted_source_list[s]
        if (!(src in source_packages)) continue
        
        printf "\n###----------[ %s ]----------###\n", src >> install_file
        
        n = split(source_packages[src], pkg_arr, "|")
        for (i = 1; i <= n; i++) {
            name = pkg_arr[i]
            if (name == "") continue
            
            pkg_key = src "_" name
            directory = packages[pkg_key, "directory"]
            url = packages[pkg_key, "url"]
            pkg_source = packages[pkg_key, "source"]
            
            install_cmd = commands[pkg_source, "install"]
            
            # Substitute variables (keep relative paths)
            gsub(/%name/, name, install_cmd)
            gsub(/%dir/, directory, install_cmd)
            gsub(/%url/, url, install_cmd)
            gsub(/%dotfiles/, dotfiles_dir, install_cmd)
            gsub(/\$HOME/, home, install_cmd)
            
            printf "%s\n", install_cmd >> install_file
        }
    }
    
    printf "\n### End of %s/install_system ###\n", output_dir >> install_file
    close(install_file)
    
    # ========== GENERATE UPDATE SCRIPT ==========
    update_file = output_dir "/update_system"
    printf "#!/bin/sh\n\n" > update_file
    printf "# This file was automatically generated with\n" >> update_file
    printf "# Level: %d\n", target_level >> update_file
    printf "\n### From {%d} sources\n\n", source_count_sorted >> update_file
    
    for (s = 1; s <= source_count_sorted; s++) {
        src = sorted_source_list[s]
        if (src == "" || !(src in source_packages)) continue
        
        # Skip git, curl, ln (no update/upgrade/clean commands needed)
        if (src == "git" || src == "curl" || src == "ln") {
            continue
        }
        
        # Check if this source has any update-related commands
        update_cmd = commands[src, "update"]
        upgrade_cmd = commands[src, "upgrade"]
        clean_cmd = commands[src, "clean"]
        
        if (update_cmd == "" && upgrade_cmd == "" && clean_cmd == "") {
            continue
        }
        
        printf "\n###----------[ %s ]----------###\n", src >> update_file
        
        if (update_cmd != "") {
            gsub(/\$HOME/, home, update_cmd)
            printf "%s\n", update_cmd >> update_file
        }
        
        if (upgrade_cmd != "") {
            gsub(/\$HOME/, home, upgrade_cmd)
            printf "%s\n", upgrade_cmd >> update_file
        }
        
        if (clean_cmd != "") {
            gsub(/\$HOME/, home, clean_cmd)
            printf "%s\n", clean_cmd >> update_file
        }
    }
    
    printf "\n### don't forget to add a cronjob\n" >> update_file
    printf "#@reboot        root    $HOME/.multi_to0l/unix/user/update_user\n" >> update_file
    close(update_file)
    
    # ========== GENERATE REMOVE SCRIPT ==========
    remove_file = output_dir "/clean_system"
    printf "#!/usr/bin/env bash\n\n" > remove_file
    printf "# This file was automatically generated with\n" >> remove_file
    printf "# Level: %d\n", target_level >> remove_file
    printf "\n### From {%d} sources {0} packages to remove\n\n", source_count_sorted >> remove_file
    
    for (s = 1; s <= source_count_sorted; s++) {
        src = sorted_source_list[s]
        if (!(src in source_packages)) continue
        
        # Check if there's a remove command
        remove_sample = commands[src, "remove"]
        if (remove_sample == "") {
            printf "\n# %s - no remove command available\n" >> remove_file
            continue
        }
        
        printf "\n###----------[ %s ]----------###\n", src >> remove_file
        
        n = split(source_packages[src], pkg_arr, "|")
        for (i = 1; i <= n; i++) {
            name = pkg_arr[i]
            if (name == "") continue
            
            pkg_key = src "_" name
            directory = packages[pkg_key, "directory"]
            pkg_source = packages[pkg_key, "source"]
            
            remove_cmd = commands[pkg_source, "remove"]
            
            # Substitute variables (keep relative paths)
            gsub(/%name/, name, remove_cmd)
            gsub(/%dir/, directory, remove_cmd)
            gsub(/\$HOME/, home, remove_cmd)
            
            if (remove_cmd != "") {
                printf "%s\n", remove_cmd >> remove_file
            }
        }
    }
    
    printf "\n### End of %s/clean_system ###\n", output_dir >> remove_file
    close(remove_file)
    
    # ========== SUMMARY ==========
    printf "Generated profile (level %d) with %d sources and %d packages:\n", target_level, source_count_sorted, total_packages
    for (s = 1; s <= source_count_sorted; s++) {
        src = sorted_source_list[s]
        if (src in source_pkg_count) {
            printf "  - %s: %d packages\n", src, source_pkg_count[src]
        }
    }
}
