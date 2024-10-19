### Own Package Manager

- [ ] Create arch linux vm 0
- [ ] Copy arch linux vm 1
- [ ] create a script that can be curl/git and sh
    - [ ] dll config_manager and launch it
        - [ ] minimal dependencies
        - [ ] config_manager has an init, create, save, active

### build_active_config

- [ ] should error message when a packages need to be installed/removed and the program dit not find the command

- [x] while parsing packages file >> creating the list of selected packages to install and clean
- [x] create generate_install_script function
- [x] create generate_clean_script function

- [ ] add option to the program to specify with mod we want diff/saving/creating we could combine different option -dsc
    - b build session
    - c create conf
    - d diff
    - s save
    - r rebuild
    - u update
- [ ] diff specifique package manager list against already install / not installed
- [ ] saving a specifique install/clean/update to a specify folder and call it a specifique config
- [ ] can we make the script more bound to the header column of the CSV

### create_config

- [ ] only proposed available source in packages
- [ ] test listed source for availability
- [ ] only list interface and context for the remaining packages

- [ ] multi user support
    - [ ] create profile for a $USER
        - [ ] active config is in >> /active/profile.conf
