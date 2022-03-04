# Arch Install Bash Script (UEFI)

## About

Custom Arch Linux semi-unattended installation script. Purpose is to install Arch on your computer quickly and efficiently. Script depends on UEFI boot mode and an active internet connection and will exit right away if either are not found.

User details, display manager, desktop environment, timezone...etc can be set at the top of the install.sh. It will prompt you at the very end to set root and super user password. Reboot and enjoy Arch :)

## Instructions

1. Update mirrors

> pacman -Syu

2. Install Git in arch-install environment

> pacman -S git

3. Clone Files to arch-install

> git clone https://github.com/fetchcat/linux-scripts.git

4. Make install script executable

> chmod +x linux-scripts/arch/install.sh

5. Edit script for your system eg. locale, timezone, super user...etc.

> nano linux-scripts/arch/install.sh

6. Run Arch install script

> ./linux-scripts/arch/install.sh

## Post Install Recommendations

1. Install [Paru AUR Helper](https://github.com/Morganamilo/paru)
2. For BTRFS Filesystem

- [zramd](https://aur.archlinux.org/packages/zramd/) for swap
- [grub-btrfs](https://archlinux.org/packages/community/any/grub-btrfs/) for grub-accessible BTRFS snapshots
