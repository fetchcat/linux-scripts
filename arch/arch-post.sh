#! /usr/bin/bash

### --- Arch Linux Post-Install Script for Meshified --- ###

# - Install Yay - #

sudo pacman -S --needed git base-devel
cd ~/Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# - Candy & Colours - #

sed -i '/\[options\]/a ILoveCandy \nColor' /etc/pacman.conf
sudo pacman -Syu

# - Nordic theme, Papirus icons, Pfetch
yay -S --noconfirm nordic-theme-git papirus-icon-theme-git nerd-fonts-meslo vimix-cursors pfetch papirus-folders-git

sh -c "$(curl -fsSL https://starship.rs/install.sh)"

echo -e '# - Starship Prompt - #\neval "$(starship init bash)"' >> ~/.bashrc

# - Mount Drives - #

sudo pacman -S --needed --noconfirm ntfs-3g sshfs

sudo echo -e '# - Storage - #\nUUID=a1061302-8f8a-4cfb-a221-8da5f9c52614 /Storage ext4 defaults 0 2\n' >> /etc/fstab

sudo echo -e '# - MediaDrive - #\nUUID=FCB26580B265406E /MediaDrive ntfs uid=1000,gid=1000,defaults 0 2\n' >> /etc/fstab

sudo echo -e '# - Elements - #\nsshfs#pi@10.10.10.3:/Elements /Elements fuse.sshfs defaults 0 0\n' >> /etc/fstab

# - PlexMediaServer - #

yay --noconfirm -S plex-media-server
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# sudo pacman -S ufw
# sudo ufw default allow outgoing
# sudo ufw default deny incoming
# sudo ufw allow 22
