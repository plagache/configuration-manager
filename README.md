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

## Fonts (manual)

Fonts are installed by hand, not by this repository. Nerd Fonts publishes
patched fonts only as release archives (`Hack.tar.xz`, `0xProto.zip`, ...), and
the archives are not uniform: some contain one font, some contain many, and the
names vary (`...NerdFontMono-Regular.ttf`, `...NerdFont-Regular.ttf`,
`...NerdFontPropo-Regular.ttf`, ...). Pick what you need from:

https://github.com/ryanoasis/nerd-fonts/releases

Example:
```sh
curl -fLo Hack.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.tar.xz
tar -xf Hack.tar.xz
mkdir -p "$HOME/.local/share/fonts"
cp HackNerdFontMono-Regular.ttf "$HOME/.local/share/fonts/"
fc-cache -f        # Linux; on macOS copy to ~/Library/Fonts instead
```

## Todo
- how to tree-sitter-cli
- add npm or nvm
- when to replace with bun
- do we need node
