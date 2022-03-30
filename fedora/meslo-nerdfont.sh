#! /usr/bin/bash

## Meslo Nerd Font

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
mkdir -p ~/.local/share/fonts
unzip Meslo.zip -d ~/.local/share/fonts/
fc-cache -v