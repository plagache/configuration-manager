## Objectives

- build session
    - create script install;update;clean
    - post install action ? services to enable ? Other Config file to add, e.g. kanata config file (script that check and replace already exist) ?
    - packages not in the list of data with special install
        - [ ] Neovim for different architecture
        - [ ] UV
        - [ ] nextcloud has been integrated with the NIXOS server
- detect change from session / and packages

## limitations

sometimes i do not have privilages
access to base tool, language, available on any mac or linux
- AWK to parse data, #!/bin/sh

how do we query the information from the system ?
what is your package manager ?
    - case: at school i detected apt but do not have sudo right and therefore should not use this package manager
    - also it did not detect brew, it was not installed and it should only download a small amount of packages from brew since
    - i should strive to install things in the simplest way possible: git/curl/install.sh
what are your packages ?

is a program nescessary or not ?

set flag for git i owned or not, in context seems relevant

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


- [ ] pacman -Scc does not have a --noconfirm options
- [ ] removing unused packages is another matter | https://gist.github.com/rumansaleem/083187292632f5a7cbb4beee82fa5031

- [x] chmod the new script
- [x] set active directory to $PATH with install script
- [x] replace stow with ln -s
- [x] remove the interactive part of config creation, too complex for no reason, we generate one
- [x] replace base tags with minimal for easier comprehension

- [ ] add services
    - [ ] the service could be enable by install
    - [ ] and could be turned off with disable

- [ ] create a script that can be curl/git and sh for example: `curl -LsSf https://astral.sh/uv/install.sh | sh`
    - [ ] dll its own git config_manager and launch it
        - [ ] minimal dependency check before run

- [ ] should error message when a packages need to be installed/removed and the program dit not find the command

- [ ] diff specifique package manager list against already install / not installed
- [ ] saving a specifique install/clean/update to a specify folder and call it a specifique config
- [ ] can we make the script more bound to the header column of the CSV

- [ ] multi user support
    - [ ] create profile for a $USER
        - [ ] active config is in >> /active/profile.conf

### TEST

- [ ] test creating session on different system
- [ ] Error handling
- [ ] create a scrip that test all the packages with their corresponding sources (--version should suffice)
