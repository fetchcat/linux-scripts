#!/usr/bin/sh

### --- Arch Install Script Configuration --- ###

## Localization and host ##

CONSOLE_KEYMAP="us"
TIMEZONE="America/Vancouver"
LOCALE="en_US.UTF-8"
REFLECTOR_COUNTRIES="CA,US"
HOSTNAME="Arch"                        

## Install disk and partition scheme ##
                                      
INSTALL_DISK="/dev/vda"
SWAP_PARTITION_SIZE="8G" # ext4 only. For btrfs, use zram from AUR
ROOT_FILESYSTEM="btrfs" # ext4 or btrfs.

## Desktop Environment - eg. KDE ##

DESKTOP_ENVIRONMENT=(
  "plasma-desktop"
  "dolphin"
  "dolphin-plugins"
  "konsole"
  "ark"
  "kwrite"
  "plasma-pa"
  "plasma-nm"
  "kdeplasma-addons"
  "kde-gtk-config"
  "kscreen"
  "kinfocenter"
  "plasma-browser-integration"
  "plasma-systemmonitor"
  "systemsettings"
  "sddm-kcm"
  "discover"
  "packagekit-qt5"
)

## Display Manager ##

DISPLAY_MANAGER="sddm" # gdm, sddm or lightdm

## Super User (added to wheel group)

SUPER_USER="arch"

## Choose which kernel to install (eg. linux-zen, linux or linux-lts)

KERNEL="linux-zen"

## Microcode for processor ##

MICROCODE="amd"

## Base installation packages for pacstrap to install ##

PACSTRAP=(
  "base"
  "$KERNEL"
  "linux-firmware"
  "vim" 
  "nano" 
  "ntfs-3g"
  "btrfs-progs"
  "networkmanager" 
  "alsa-utils" 
  "wget" 
  "curl" 
  "rsync"
  "grub"
  "efibootmgr"
  "reflector"
  "xorg"
  "sudo"
  "os-prober"
  "xdg-utils"
  "xdg-user-dirs"
)

### --- --- --- Installation --- --- --- ###

# - Status Messages - #

# eg. statusmsg "info" "Installing package..." (shows blue)
# eg. statusmsg "success" "Success!" (shows green)
# eg. statusmsg "error" "Error!" (shows red)

statusMsg() {
	case "$1" in 
		"error" )
		echo -e "\e[91m-> $2\e[0m"
		;;
		"info" )
		echo -e "\e[94m-> $2\e[0m"
		;;
		"success" )
		echo -e "\e[92m-> $2\e[0m"
		;;	
		*) 
		echo "No status type specified"
		;;
	esac
}

## Check EFI ##

if [ "$(ls -A /sys/firmware/efi/efivars)" ]; then
  statusMsg "success" "EFI Mode detected. Proceeding with install"
else
  statusMsg "error" "Legacy BIOS mode detected. Installation aborted"
  exit 1
fi

## Set console keyboard layout ##

loadkeys $CONSOLE_KEYMAP

## Use NTP ##

timedatectl set-ntp true

## Test Internet - will stop script if no net. ##

if nc -zw1 google.com 80; then
  statusMsg "success" "Internet connection detected"
else
  statusMsg "error" "No internet connection"
  exit 1
fi

## Partition disk ##

statusMsg "info" "Partitioning $INSTALL_DISK"

case $ROOT_FILESYSTEM in
  ext4)
    parted --script $INSTALL_DISK \
      mklabel gpt \
      mkpart primary fat32 1MiB 512MiB \
      name 1 "EFI" \
      set 1 esp on \
      mkpart primary linux-swap 513MiB $SWAP_PARTITION_SIZE \
      mkpart primary ext4 $SWAP_PARTITION_SIZE 100% \
      name 3 "ROOT"

    # Easy Partition Vars
    EFI_PART="${INSTALL_DISK}1"
    SWAP_PART="${INSTALL_DISK}2"
    EXT4_PART="${INSTALL_DISK}3"

    mkfs.fat -F32 $EFI_PART
    mkswap $SWAP_PART
    mkfs.ext4 $EXT4_PART

    statusMsg "info" "Mounting volumes on: $INSTALL_DISK"

    mount $EXT4_PART /mnt
    mkdir -p /mnt/boot
    mount $EFI_PART /mnt/boot

    swapon $SWAP_PART
    statusMsg "success" "Sucessfully formatted $INSTALL_DISK as ext4"
    break
    ;;
  btrfs)
    parted --script $INSTALL_DISK \
      mklabel gpt \
      mkpart primary fat32 1MiB 350MiB \
      set 1 esp on \
      name 1 "EFI" \
      mkpart primary btrfs 351MiB 100% \
      name 2 "ROOT"

    # Easy Partition Vars
    EFI_PART="${INSTALL_DISK}1"
    BTRFS_PART="${INSTALL_DISK}2"

    mkfs.vfat $EFI_PART
    mkfs.btrfs $BTRFS_PART

    statusMsg "info" "Mounting volumes on: $INSTALL_DISK"

    mount $BTRFS_PART /mnt
    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@var
    umount /mnt

    mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ $BTRFS_PART /mnt

    mkdir -p /mnt/{boot,home,var}

    mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@home $BTRFS_PART /mnt/home

    mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@var $BTRFS_PART /mnt/var

    mount $EFI_PART /mnt/boot

    statusMsg "success" "Sucessfully formatted $INSTALL_DISK as btrfs"
    break
    ;;
  *)
    statusMsg "error" "Filesystem type unavailable"
    return
esac

## Install base Arch packages ##

statusMsg "info" "Installing base packages"

for i in ${PACSTRAP[@]};
do
  pacstrap /mnt $i
done

## Generate FSTAB ##

statusMsg "info" "Generating FSTAB"

genfstab -U /mnt >> /mnt/etc/fstab

## Set timezone ##

statusMsg "info" "Setting timezone"

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

## Set clock ##

statusMsg "info" "Setting hardware clock"

arch-chroot /mnt hwclock --systohc

## Set Locale ##

statusMsg "info" "Setting locale as: $LOCALE"

echo "$LOCALE UTF-8" >> /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

## Set language ##

echo "LANG=$LOCALE" >> /mnt/etc/locale.conf

## Set console keymap ##

statusMsg "info" "Setting console keymap as: $CONSOLE_KEYMAP"

echo "KEYMAP=$CONSOLE_KEYMAP" >> /mnt/etc/vconsole.conf

## Set Hostname ##

statusMsg "info" "Setting hostname as: $HOSTNAME"

echo "$HOSTNAME" >> /mnt/etc/hostname

## Install GRUB to boot partition ##

statusMsg "info" "Installing Grub"

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

sed -i "s/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/" /mnt/etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

## Enable NetworkManager ##

statusMsg "info" "Enabling NetworkManager"

arch-chroot /mnt systemctl enable NetworkManager

## Generate Pacman mirrors with Reflector ##

statusMsg "info" "Generating best mirrors"

reflector --country "$REFLECTOR_COUNTRIES" --protocol http,https --sort rate -l 10 --save /mnt/etc/pacman.d/mirrorlist

## Update Pacman repos ##

statusMsg "info" "Updating mirrors"

arch-chroot /mnt pacman -Syu --noconfirm

## Install CPU microcode ##

statusMsg "info" "Installing $MICROCODE microcode"

arch-chroot /mnt pacman -S --noconfirm "$MICROCODE-ucode"

## Enabling BTRFS Module ##

if [ $ROOT_FILESYSTEM == "btrfs" ]; 
  then
    statusMsg "info" "Creating initial ramdisk environment with btrfs support"
    sed -i "s/MODULES=()/MODULES=(btrfs)/" /etc/mkinitcpio.conf
fi

arch-chroot /mnt mkinitcpio -p $KERNEL

## Install packages for desktop environment ##

statusMsg "info" "Installing Desktop Environment"

for pkg in ${DESKTOP_ENVIRONMENT[@]};
  do
    arch-chroot /mnt pacman -S --noconfirm $pkg
  done

## Install and enable display manager ##

statusMsg "info" "Installing and enabling Display Manager: $DISPLAY_MANAGER"

arch-chroot /mnt pacman -S --noconfirm $DISPLAY_MANAGER
arch-chroot /mnt systemctl enable $DISPLAY_MANAGER

## Adds super user to system and wheel group ##

statusMsg "info" "Setting permissions for super user: $SUPER_USER"

arch-chroot /mnt useradd -mG wheel -s /bin/bash $SUPER_USER
# arch-chroot /mnt sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers

# arch-chroot /mnt visudo << EOF
# :%s/^# %wheel ALL=(ALL) NO/%wheel ALL=(ALL) NO/g
# :wq
# EOF

echo -e "%wheel ALL=(ALL) ALL\nDefaults rootpw" > /etc/sudoers.d/99_wheel 

## Set passwords ##

echo -e "Set Root password: "
arch-chroot /mnt /bin/passwd

echo -e "Set password for $SUPER_USER: "
arch-chroot /mnt /bin/passwd "$SUPER_USER"

## Unmounts drive ##

umount -Rl /mnt

## Done ##

statusMsg "success" "Finished installing Arch. You may now reboot"
