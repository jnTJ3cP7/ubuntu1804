#!/bin/bash

sudo apt update -y
sudo apt full-upgrade -y

###################
### Gui install ###
###################
# This is needed to execute first because if this is last, unexpected update execute.
sudo apt install -y lubuntu-desktop

#############################
### Guest Addition update ###
#############################
# Need for screen resolution because vbguest plugin don't work for this.
sudo apt install -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

############################
### Baseic info settings ###
############################
sudo update-locale LC_ALL=C.UTF-8
sudo timedatectl set-timezone Asia/Tokyo

sudo apt install -y fcitx-mozc

###########
### Zsh ###
###########
sudo apt install -y \
	zsh
# curl is installed above
curl -OL https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
# login user password need to be username
#TODO login user password settings
echo -e $(whoami) | sh install.sh
rm -f install.sh
git clone --depth 1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
cat << EOS >> ~/.zshrc

# for zsh-completions
plugins=(… zsh-completions)
autoload -U compinit && compinit

EOS

sudo apt autoremove -y
