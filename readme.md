list of things to do


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

