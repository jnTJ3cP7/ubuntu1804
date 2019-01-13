#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - python
###################################################
source ~/.zshrc 2>/dev/null
! which pyenv >/dev/null && echo 'please provision pyenv before docker provision' && exit 1

sudo apt install -y \
	apt-transport-https \
	ca-certificates \
	software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
sudo apt update -y
# old version specified for minikube. docker version suffix no longrer '-ce', but minikube can't do it.
sudo apt install -y docker-ce=18.06.1~ce~3-0~ubuntu || {echo 'docker install failed' && exit 1}
sudo apt autoremove -y

sudo gpasswd -a $USER docker

pip install docker-compose --upgrade || {echo 'docker-compose install failed' && exit 1}

sudo systemctl restart docker.service
