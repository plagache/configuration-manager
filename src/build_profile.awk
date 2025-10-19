#!/usr/bin/awk -f

BEGIN {
    FS = ","

    home_dir = ENVIRON["HOME"]

    if (profile_name == "") {
        print "Warning: No Profile Name has been provided\n"
    }

    profile_directory = "./profile/" profile_name
    config_file = profile_directory "/" profile_name ".csv"

    if (config_file == "") {
        print("no config file has been given backing on", config_file)
    }
    if (commands_file == "") {
        print("no commands file has been given backing on", commands_file)
    }
    if (packages_file == "") {
        print("no packages file has been given backing on", packages_file)
    }


    read_config(config_file)
    read_commands(commands_file)
    read_packages(packages_file)

    update_file = profile_directory "/update_" profile_name
    clean_file = profile_directory "/clean_" profile_name
    install_file = profile_directory "/install_" profile_name

    generate_update_script(update_file)
    generate_remove_script(clean_file)
    generate_install_script(install_file)
}

function read_config(file) {
    config_counter = 0
    source_count = 0
    while ((getline < file) > 0) {
        if ($1 != "") {
            config_sources[config_counter] = $1
            source_count++
        }
        if ($2 != "") {
            config_interfaces[config_counter] = $2
        }
        if ($3 != "") {
            config_contexts[config_counter] = $3
        }
        config_counter++
    }
    close(file)
}

function read_commands(file) {
    while ((getline < file) > 0) {
        if ($1 == "" || $1 == "source") {
            continue
        }
        for (source_iterator in config_sources) {
            if (config_sources[source_iterator] == $1) {
                config_sources[source_iterator, "update"] = $2
                config_sources[source_iterator, "upgrade"] = $3
                config_sources[source_iterator, "clean"] = $4
                config_sources[source_iterator, "install"] = $5
                config_sources[source_iterator, "remove"] = $6
            }
        }
    }
    close(file)
}

function match_package_config(package_name, context, interface) {
    stock_interface = ""
    for (counter in config_interfaces) {
        if (config_interfaces[counter] == interface) {
            stock_interface = "active"
            break
        }
    };
    stock_context = ""
    for (counter in config_contexts) {
        if (config_contexts[counter] == context) {
            stock_context = "active"
            break

        }
    }
    if (stock_context == "active" && stock_interface == "active") {
        return 1
    }
    else if (stock_context != "active" || stock_interface != "active") {
        return 0
    }
}

function build_package_command(action, source, name, directory, url, package_number) {
    if (source == "git") {
        if (action == "install") {
            packages[source, action, package_number] = url " " ENVIRON["HOME"] "/" directory
        }
        if (action == "remove") {
            packages[source, action, package_number] = ENVIRON["HOME"] "/" directory
        }
    }
    else if (source == "curl") {
        if (action == "install") {
            packages[source, action, package_number] = ENVIRON["HOME"] "/" directory " " url
        }
        if (action == "remove") {
            packages[source, action, package_number] = ENVIRON["HOME"] "/" directory
        }
    }
    else {
        packages[source, action, package_number] = name
    }
}

function read_packages(file) {
    package_counter = 1
    package_install = 0
    package_remove = 0
    while ((getline < file) > 0) {
        if ($1 == "" || $1 == "source") {
            continue
        }

        package_source = $1
        for (source_iterator in config_sources) {
            source = config_sources[source_iterator]
            if (source == package_source) {
                package_name = $2
                package_interface = $3
                package_context = $4
                package_directory = $5
                package_url = $6
                if (match_package_config(package_name, package_context, package_interface) == 1) {
                    build_package_command("install", source, package_name, package_directory, package_url, package_install)
                    package_install++
                }
                else if (match_package_config(package_name, package_context, package_interface) == 0) {
                    build_package_command("remove", source, package_name, package_directory, package_url, package_remove)
                    package_remove++
                }
            }
        }
        package_counter++
    }
    close(file)
}

function generate_update_script(update_file) {
    printf("#!/bin/sh\n\n") > update_file
    printf("# This file was automatically generated with %s\n\n", script_file) >> update_file
    # printf("# set -eu\n\n") >> update_file
    printf("### From {%d} sources\n", source_count) >> update_file

    for (source_iterator = 0; source_iterator < source_count; source_iterator++) {
        if (config_sources[source_iterator, "update"] != "" || config_sources[source_iterator, "upgrade"] != "" || config_sources[source_iterator, "clean"] != "") {
            printf("\nprintf '\\n========== %s ==========\\n'\n\n", config_sources[source_iterator]) >> update_file
        }
        else if (config_sources[source_iterator, "update"] == "" && config_sources[source_iterator, "upgrade"] == "" && config_sources[source_iterator, "clean"] == "") {
            printf("\n# No command found for [%s]\n", config_sources[source_iterator]) >> update_file
        }

        if (config_sources[source_iterator, "update"] != "") {
            printf("printf '\\n>>> Updating %s...\\n\\n'\n", config_sources[source_iterator]) >> update_file
            printf("%s\n", config_sources[source_iterator, "update"]) >> update_file
        }

        if (config_sources[source_iterator, "upgrade"] != "") {
            printf("printf '\\n>>> Upgrading %s...\\n\\n'\n", config_sources[source_iterator]) >> update_file
            printf("%s\n", config_sources[source_iterator, "upgrade"]) >> update_file
        }

        if (config_sources[source_iterator, "clean"] != "") {
            printf("printf '\\n>>> Cleaning %s...\\n\\n'\n", config_sources[source_iterator]) >> update_file
            printf("%s\n", config_sources[source_iterator, "clean"]) >> update_file
        }
    }

    printf("\n### don't forget to add a cronjob\n") >> update_file
    printf("#@reboot        root    $HOME/.multi_to0L/unix/user/update_user\n") >> update_file
}

function generate_remove_script(clean_file) {
    printf("#!/usr/bin/env bash\n\n") > clean_file
    printf("# This file was automatically generated with %s\n\n", script_file) >> clean_file
    printf("### From {%s} sources {%s} packages to remove\n", source_count, package_remove) >> clean_file

    for (source_iterator = 0; source_iterator < source_count; source_iterator++) {
        source = config_sources[source_iterator]
        printf("\n###----------[ %s ]-----------###\n", source) >> clean_file
        for (package = 0; package <= package_install; package++){
            if (packages[source, "remove", package] != "") {
                printf("%s %s\n", config_sources[source_iterator, "remove"], packages[source, "remove", package]) >> clean_file
            }
        }
    }
    printf("\n### End of %s ###", clean_file) >> clean_file
}

function generate_install_script(install_file) {
    printf("#!/usr/bin/env bash\n\n") > install_file
    printf("# This file was automatically generated with %s\n\n", script_file) >> install_file
    printf("### From {%s} sources {%s} packages to install\n", source_count, package_install) >> install_file

    for (source_iterator = 0; source_iterator < source_count; source_iterator++) {
        source = config_sources[source_iterator]
        printf("\n###----------[ %s ]-----------###\n", source) >> install_file
        for (package = 0; package <= package_install; package++){
            if (packages[source, "install", package] != "") {
                printf("%s %s\n", config_sources[source_iterator, "install"], packages[source, "install", package]) >> install_file
            }
        }
    }
    printf("\n### End of %s ###", install_file) >> install_file
}
