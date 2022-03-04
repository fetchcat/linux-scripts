
echo -e "-> Installing curl, wget, zip utilities"
apt -y install curl wget zip unzip

cd ~/Downloads

# Install Codium, extensions and theme
echo -e "-> Installing Codium and Extensions"
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg 
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install codium

codium --install-extension zhuangtongfa.material-theme
codium --install-extension esbenp.prettier-vscode
codium --install-extension pkief.material-icon-theme

# Install Pfetch
echo -e "-> Installing Pfetch"
git clone https://github.com/dylanaraps/pfetch.git
sudo install pfetch/pfetch /usr/local/bin/
ls -l /usr/local/bin/pfetch
echo -e 'pfetch' >> ~/.bashrc

# Meslo Fonts
echo -e "-> Installing Meslo Fonts"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts/Meslo/
fc-cache -fv

# Starship Prompt

sh -c "$(curl -fsSL https://starship.rs/install.sh)"
echo -e 'eval "$(starship init bash)"' >> ~/.bashrc

# Install Nodejs
echo -e "-> Installing Nodejs v16.x"
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install -y nodejs