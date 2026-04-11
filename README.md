# configuration-manager
Started as a collection of scripts

## Installation and dependencies

You need ssh keys for your different repositories

You need git, awk and find
```sh
git clone git@github.com:plagache/configuration-manager.git
cd configuration-manager
./install
```

finally we can use 
```sh
~/.local/bin/install_system
~/.local/bin/remove_system
~/.local/bin/update_system
```

to finish you need to set your shell
```sh
chsh -s $(which zsh)
```

a few script/commands from base can be run:
```sh
install_nvim
install_nvm
curl -fsSL https://opencode.ai/install | bash
```

## Todo
how tree-sitter-cli
add fd-find, npm or nvm
when to replace with bun
do we need node ?
