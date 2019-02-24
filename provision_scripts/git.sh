#!/bin/zsh

# TODO config settings for git (e.g. pull option, mailaddress, username etc...)

if ! {sudo find /etc/apt -name '*git-core*.list' -type f | egrep -q '.*'}; then
  sudo add-apt-repository -y ppa:git-core/ppa
fi

sudo apt update -y
sudo apt install -y git
sudo apt autoremove -y
