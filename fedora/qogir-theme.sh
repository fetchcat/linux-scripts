#! /usr/bin/bash

## Theme

gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
dnf install gtk-murrine-engine gtk2-engines

git clone https://github.com/vinceliuice/Qogir-theme.git
cd Qogir-theme
./install.sh -t all -l fedora