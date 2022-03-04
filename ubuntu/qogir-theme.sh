#! /bin/bash

# Qogir Theme with dependencies

gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close

sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf libsass1 sassc

cd ~/Downloads
git clone https://github.com/vinceliuice/Qogir-theme.git
cd Qogir-theme
./install.sh -t all -l ubuntu 