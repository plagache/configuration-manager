# configuration-manager
Started as a collection of scripts

## Installation and dependencies

You need ssh keys for your different repositories

You need git, awk and find to compile the scripts
```sh
git clone git@github.com:plagache/configuration-manager.git
cd configuration-manager
./install
```

Goto
```sh
cd ${HOME}/.local/bin
```

Run
```sh
${HOME}/.local/bin/update_system
${HOME}/.local/bin/clean_system
${HOME}/.local/bin/install_system
```

Setup your shell
```sh
chsh -s $(which zsh)
```

Others
```sh
install_nvim
install_nvm
curl -fsSL https://opencode.ai/install | bash
```

## Todo
- how to tree-sitter-cli
- add npm or nvm
- when to replace with bun
- do we need node
