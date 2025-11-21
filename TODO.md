how do we query the information from the system ?
what is your package manager ?
what are your packages ?

less tags, is a program nescessary or not ?

set flag for git i owned or not, in context seems relevant

- replace stow with ln -s

- interface should be removed for something like Right, do we need Admin ?

- what tags for curl, or git, maybe some tags about extra installation step

check should be like this:
sh
```
!ssh_keys
    install git not owned
!stow_flag
    backup to ln -s
!config_file_found
    generate one for the current system
```

- [ ] remove the interactive part of config creation, too complex for no reason, we generate one

- [ ] pacman -Scc does not have a --noconfirm options
- [ ] removing unused packages is another matter | https://gist.github.com/rumansaleem/083187292632f5a7cbb4beee82fa5031
- [ ] Add a backup for Stow >> Manual ln -s
- [ ] Introduce more expressiveness e.g. change create for create_new_configuration, create_scripts or create_user_files
- [ ] Decouple interactions | if scripts could be independant, it would be great

- [ ] Add dry run optiont: features that show the changes that would be applied without executing them
- [ ] Error handling
- [x] chmod the new script
- [x] set active directory to $PATH with install script
- [ ] read packages.csv and is able to rebuild it / check homogenous number of column and add them if nescessary
- [x] replace base tags with minimal for easier comprehension
- [ ] add services
    - [ ] how to treat configuration file ? diff? how to treat the service in it self enable and start
    - [ ] enable for install
    - [ ] disable for remove
- [ ] list available configuration and allow for selection

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

- [x] only proposed available source in packages
- [x] test listed source for availability
- [x] only list interface and context for the remaining packages

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
