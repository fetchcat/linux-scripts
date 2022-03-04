# Download all files first to Downloads

cd ~/Downloads

# Install Codium

sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg

printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo

dnf install codium

codium --install-extension zhuangtongfa.material-theme
codium --install-extension esbenp.prettier-vscode
codium --install-extension pkief.material-icon-theme

# One Dark Gnome Terminal Theme
bash -c "$(curl -fsSL https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-dark.sh)"

# Install Node/Npm (Minimal)

dnf module install nodejs:16/minimal

# Install Plex

tee /etc/yum.repos.d/plex.repo<<EOF
[Plexrepo]
name=plexrepo
baseurl=https://downloads.plex.tv/repo/rpm/\$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1
EOF

dnf update
dnf install plexmediaserver
systemctl enable plexmediaserver

# Install Chromium

dnf install chromium

# TODO - Cronie script

dnf install cronie
systemctl start crond
systemctl enable crond
crontab -e

## add "0 1 * * * ./home/michelle/Code/scripts/backup-pi.sh"

# TODO - install + script Steam/Lutris/Gamemode/AMD Mesa

# RPM Fusion

dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Multimedia Codecs

dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf install lame\* --exclude=lame-devel
dnf group upgrade --with-optional Multimedia


