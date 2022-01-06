#! /usr/bin/bash

### --- Arch linux install script --- ###

# - Timezone and Locale/Language - #

TIMEZONE="America/Vancouver"
LOCALE="en_US.UTF-8"

# - Adds colours standard echo - #

# eg. statusmsg "info" "Installing package..." (shows blue)
# eg. statusmsg "success" "Success!" (shows green)
# eg. statusmsg "error" "Error!" (shows red)

statusMsg() {
	case "$1" in 
		"error" )
		echo -e "\e[31m-> $2\e[0m"
		;;
		"info" )
		echo -e "\e[94m-> $2\e[0m"
		;;
		"success" )
		echo -e "\e[32m-> $2\e[0m"
		;;	
		*) 
		echo "No status type specified"
		;;
	esac
}

# - Language, time and locale - #

set_ntp () {
  statusMsg "info" "Setting NTP"
  timedatectl set-ntp true
}

set_timezone () {
  statusMsg "info" "Setting Timezone to $TIMEZONE"
  ln -sf /usr/share/zoneinfo/$TIMEZONE /mnt/etc/localtime
}

set_locale () {
  mkdir /mnt/etc/                        
  statusMsg "info" "Setting Locale ($LOCALE)"
  touch /mnt/etc/locale.gen
  touch /mnt/etc/locale.conf
  echo "$LOCALE UTF-8" > /mnt/etc/locale.gen
  echo "LANG=$LOCALE" > /mnt/etc/locale.conf
}

# - Hostname - #

set_hostname () {
  if [ ! -d /mnt/etc ]; then
  mkdir /mnt/etc
  fi
  read -r -p "Hostname: " HOSTNAME
  if [ -z "$HOSTNAME" ]; 
    then
      statusMsg "error" "Please enter a hostname..."
      hostname_selector
  fi
  echo "$HOSTNAME" > /mnt/etc/hostname
  statusMsg "success" "Setting Hostname to $HOSTNAME"
}

# - Generate hosts file - #

set_hosts () {
  if [ ! -d /mnt/etc ]; then
  mkdir /mnt/etc
  fi
  statusMsg "info" "Creating hosts file"
  cat > /mnt/etc/hosts << EOF
  127.0.0.1 localhost
  127.0.1.1 $HOSTNAME.local $HOSTNAME
EOF
}

# - Kernel selector - #

kernel_selector () {
  echo "Select Linux Kernel"
  echo "A: Stable (Vanilla)"
  echo "B: Zen (Performance)"
  read -r -p "Select Kernel (A or B): " choice
  case $choice in 
    [aA]) kernel="linux"
      ;;
    [bB] ) kernel="linux-zen"
      ;;
    * ) echo "Please select a kernel (A or B)"
    kernel_selector
  esac                                        
}

# - Shows disks with size to install Arch on - #

select_disk () {
  statusMsg "info" "Available Disks:"
  statusMsg "info" "------------"
  lsblk -dn --output NAME,SIZE
  statusMsg "info" "------------"
  PS3="Please Select drive to install to (eg. sda, vda): " 
  select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");
  do
      DISK=$ENTRY
      statusMsg "success"  "Installing Arch Linux on $DISK."
      break
  done
}

# - Formats disk, then prompts for chice of EXT4 or BTRFS - #

format_disk () {
  read -r -p "Destroy all data on $DISK [y/N]? " response

  response=${response,,}
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    statusMsg "info" "Wiping $DISK."
    wipefs -af "$DISK"
    sgdisk -Zo "$DISK"
  else
  statusMsg "error" "Quitting."
    exit
  fi
  PS3="Please Select installation type: " 
  select filesystem in EXT4 BTRFS;
  do
    case $filesystem in
      EXT4) ext4_bootstrap
      break
      ;;
      BTRFS) btrfs_bootstrap
      break
      ;;
      *) statusMsg "error"  "No filesystem specified"
      ;;
    esac
  done
}

# - Use BTRFS filesystem with Ubuntu-style subvolumes - #

btrfs_bootstrap () {
  statusMsg "info" "Creating the partitions on $DISK."
  parted -s "$DISK" \
    mklabel gpt \
    mkpart primary fat32 1MiB 513MiB \
    name 1 BOOT \
    set 1 esp on \
    mkpart primary 513MiB 100% \
    name 2 ROOT \

  statusMsg "info" "Formatting EFI Partition"
  mkfs.fat -F32 /dev/disk/by-partlabel/BOOT

  statusMsg "info" "Formatting Root Partition as BTRFS"
  mkfs.btrfs -L ROOT /dev/disk/by-partlabel/ROOT
  
  statusMsg "info" "Mounting Root Partition"
  mount /dev/disk/by-partlabel/ROOT /mnt

  statusMsg "info" "Creating BTRFS Subvolumes"
  for volume in @ @home @snapshots
  do
    btrfs su cr /mnt/$volume
  done

  umount /mnt

  statusMsg "info" "Mounting Subvolumes"
  mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/disk/by-partlabel/ROOT /mnt
  mkdir -p /mnt/{boot,home,.snapshots}
  mount /dev/disk/by-partlabel/BOOT /mnt/boot
  mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/disk/by-partlabel/ROOT /mnt/home
  mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/disk/by-partlabel/ROOT /mnt/.snapshots
}

# - Standard EXT4 install with single partition - #

ext4_bootstrap () {
  statusMsg "info" "Creating the partitions on $DISK."
  parted -s "$DISK" \
    mklabel gpt \
    mkpart primary fat32 1MiB 513MiB \
    name 1 BOOT \
    set 1 esp on \
    mkpart primary 513MiB 100% \
    name 2 ROOT \

  statusMsg "info" "Formatting EFI Partition"
  mkfs.fat -F32 /dev/disk/by-partlabel/BOOT

  statusMsg "info" "Formatting Root Partition as ext4"
  mkfs.ext4 /dev/disk/by-partlabel/ROOT

  statusMsg "info" "Mounting Root Partition"
  mount /dev/disk/by-partlabel/ROOT /mnt
}

# - Installs GRUB bootloader - #

grub_bootstrap () {
  statusMsg "info" "Installing GRUB"
  grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB
  statusMsg "info" "Creating GRUB configuration file"
  grub-mkconfig -o /boot/grub/grub.cfg
  statusMsg "info" "Generating fstab"
  
}

# - Installs Arch base - #

pacstrap_base () {
  statusMsg "info" "Installing base system"
  pacstrap /mnt base $kernel $kernel-headers networkmanager grub efibootmgr nano alsa-utils grub rsync curl base-devel ntfs-3g nano sudo wget xdg-utils xdg-user-dirs

  statusMsg "info" "Generating FSTAB"

  genfstab -U /mnt >> /mnt/etc/fstab
}

# - Select video driver - #

video_selector() {
    PS3="Please select primary video driver: " 
    select video_driver in AMD Intel Nvidia VirtualBox
    do
      case $video_driver in
        AMD)
          arch-chroot /mnt pacman --noconfirm -S xf86-video-amdgpu
          break
          ;;
        Intel)
          arch-chroot /mnt pacman --noconfirm -S xf86-video-intel
          break
          ;;
        Nvidia)
          arch-chroot /mnt pacman --noconfirm -S nvidia nvidia-utils
          break
          ;;
        VirtualBox)
          arch-chroot /mnt pacman --noconfirm -S xf86-video-vmware virtualbox-guest-utils
          break
          ;;
        None)
          break
          ;;
        *)
          statusMsg "error" "Please select a valid Video option"
          video_selector
          ;;
      esac
    done
}

# - Select microcode - #

ucode_selector() {
    PS3="Please select CPU Microcode: " 
    select ucode in AMD Intel None
    do
      case $ucode in
        AMD)
          arch-chroot /mnt pacman --noconfirm -S amd-ucode
          break
          ;;
        Intel)
          arch-chroot /mnt pacman --noconfirm -S intel-ucode
          break
          ;;
        None)
          break
          ;;
        *)
          statusMsg "error" "Please select CPU Microcode"
          ucode_selector
          ;;
      esac
    done
}

# - Set root password and create super user - #

set_users () {
  # Set Root Password
  statusMsg "info" "Set Root Password: "
  arch-chroot /mnt /bin/passwd

  read -r -p "Super User: (or blank for none) " username
  if [ -n "$username" ]; 
    then
      arch-chroot /mnt useradd -mG wheel -s /bin/bash "$username"
      sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /mnt/etc/sudoers
      echo "Setting user password for $username." 
      arch-chroot /mnt /bin/passwd "$username"
  fi
}

# - Select Desktop - KDE, Xfce, Cinnamon or None - #

select_desktop() {
  PS3="Please Select Desktop Environment: " 
    select desktop in Xfce4 KDE Cinnamon None
    do
      case $desktop in
        Xfce4)
        statusMsg "info" "Installing Xfce4..."
        arch-chroot /mnt /bin/bash -e << EOF
        pacman --noconfirm -S xorg xfce4 xfce4-goodies xfce4-whiskermenu-plugin lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings engrampa
        systemctl enable lightdm
EOF
        break
        ;;
        KDE)
        statusMsg "info" "Installing KDE..."
        arch-chroot /mnt /bin/bash -e << EOF
        pacman --noconfirm -S plasma-desktop dolphin dolphin-plugins konsole ark kwrite plasma-nm plasma-pa kdeplasma-addons kde-gtk-config powerdevil bluedevil kscreen kinfocenter plasma-browser-integration breeze-gtk sddm sddm-kcm discover packagekit-qt5
        systemctl enable sddm
EOF
        break
        ;;
        Cinnamon)
        statusMsg "info" "Installing Cinnamon..."
        arch-chroot /mnt /bin/bash -e << EOF
        pacman --noconfirm -S xorg cinnamon lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings gnome-keyring gnome-terminal metacity leafpad engrampa guake
        systemctl enable lightdm
EOF
        break
        ;;
        None)
        statusMsg "info" "Installing no desktop environment"
        break
        ;;
        *) statusMsg "error" "No environment specified"
        select_desktop
        ;;
      esac
    done
}

#### --- Install --- ###

statusMsg "info" "Arch Install Script"

## Enable NTP
set_ntp

## Select disk to install to
select_disk

## Formats disk as either BTRFS or EXT4
format_disk

## Prompt for Hostname
set_hostname

## Auto-generate hosts file
set_hosts

## Select between Standard and Zen Kernels
kernel_selector

## Set Locale to America-Vancouver with en_US.UTF-8
set_locale

## Generates 10 best mirrors

statusMsg "info" "Generating best 10 Arch mirrors"
reflector --country 'CA,US' --protocol http,https --sort rate -l 10 --save /mnt/etc/pacman.d/mirrorlist

## Update Pacman

statusMsg "info" "Updating Pacman"
arch-chroot /mnt pacman -Syu --noconfirm

## Installs base + core utilities
pacstrap_base

## Select CPU Microcode
ucode_selector

## Select Video Driver
video_selector

## Create Users
set_users

## Sets timezone to America/Vancouver
set_timezone

# Post install, configure boot, NetworkManager, clock
arch-chroot /mnt /bin/bash -e << EOF
locale-gen
echo -e "Mounting boot"
mkdir /boot/efi
mount /dev/disk/by-partlabel/BOOT /boot/efi
echo -e "Installing GRUB"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
echo -e "Creating GRUB configuration file"
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "Setting Hardware Clock"
hwclock --systohc
systemctl enable NetworkManager
EOF

## Select Desktop
select_desktop

statusMsg "success" "Done. You can reboot :)"
exit