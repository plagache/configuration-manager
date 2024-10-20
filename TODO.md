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

### Old Readme

- [x] merged every packages in the new config file
    - [x] create new file
    - [x] add each older file to the new with awk


- [x] generate config file with bash script and awk
    - [x] determine number of column / number of options
    - [x] iterate on each column
    - [x] select a list of options for a specifique column
    - [x] print list
    - [x] ask user to enter option
    - [x] print the corresponding selected options to file
    - [x] merge each option file after iteration with paste

- [x] update packages.csv with proper interface and context

- [ ] test creating session on different system

- [ ] create a scrip that test all the packages with their corresponding sources (--version should suffice)

- [ ] rewrite setup_user_package_manager with awk script




what i think about >> the list of selected options should be narrow down to available possibilties
                    >> how i can select multiple package manager ?
                    >> case with apt and brew
                    >> case with pacman and paru
                    >> it should make command line interface with the corresponding packages
