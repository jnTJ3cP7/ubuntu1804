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

######################
### Basic settings ###
######################
sudo update-locale LC_ALL=C.UTF-8
sudo timedatectl set-timezone Asia/Tokyo

# for Japanese input from keyboard
sudo apt install -y fcitx-mozc

###########
### Zsh ###
###########
# curl is installed above so not need to install
sudo apt install -y zsh

PREZTO_DIR=${ZDOTDIR:-$HOME}/.zprezto
git clone --depth 1 --recursive https://github.com/sorin-ionescu/prezto.git $PREZTO_DIR
for zfile_path in $PREZTO_DIR/runcoms/*; do
	ZFILE_NAME="${zfile_path##*/}"
	if [ "$ZFILE_NAME" = 'README.md' ]; then
		continue
	fi
	ln -sfn "$zfile_path" "${ZDOTDIR:-$HOME}/.${ZFILE_NAME}"
done
sed '$ a' ~/.zshrc

ZSH_PATH=$(which zsh)
awk -F: -v "username=$(whoami)"  '$1 == username{print NR}' /etc/passwd | xargs -i sudo sed -i "{} s ^\(.*\):.*$ \1:$ZSH_PATH g" /etc/passwd

###################
### Other utils ###
###################
sudo apt install -y \
	jq

sudo apt autoremove -y
