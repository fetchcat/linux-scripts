# Arch Install Bash Script (Needs Fixing)

## About

Easy UEFI Arch Install to a single drive (no swap) with the following options:

- Easily choose drive to install to (shows capacity for quick identification)
- Ext4 or BTRFS filesystem (Ubuntu-style subvolumes for TimeShift)
- Minimal Xfce, KDE, Cinnamon or no desktop
- AMD or Intel Microcode
- AMD, Intel, Nvidia or VMware/Virtualbox video drivers

## Installation

1. Download latest ISO and PGP signature from [Arch Linux](https://archlinux.org/download/) website.

2. Verify ISO (Recommended)

> gpg --keyserver-options auto-key-retrieve --verify archlinux-version-x86_64.iso.sig

3. Write to USB drive with [BalenaEtcher](https://www.balena.io/etcher/) or other utility.

4. Boot from Drive and when root@archiso prompt appears run the following commands:

> pacman -Sy

> pacman -S git

> git clone https://github.com/merogers/archinstall.git

> nano archinstall/install.sh and set Timezone and Locale for your area.

> chmod +x archinstall/install.sh

> ./archinstall/install.sh

## Issues

Be sure to post any issues, otherwise enjoy :)
