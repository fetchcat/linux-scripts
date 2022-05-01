#! /bin/bash

# Ubuntu 21.10 Script

# Replace Snaps with FlatPak

sudo rm -rf /var/cache/snapd
sudo apt autoremove --purge snapd gnome-software-plugin-snap
rm -fr ~/snap
sudo apt-mark hold snapd

sudo apt install gnome-software flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt update && apt upgrade

echo -e "Be sure to reboot to enable full flatpak support"