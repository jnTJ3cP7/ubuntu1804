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

# ##############
# ### Docker ###
# ##############
# sudo apt install -y \
# 	apt-transport-https \
# 	ca-certificates \
# 	software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository \
# 	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
# 	$(lsb_release -cs) \
# 	stable"
# sudo apt update
# sudo apt install -y docker-ce
# sudo gpasswd -a $USER docker
# pip install docker-compose --upgrade
# sudo systemctl restart docker.service

# ###############
# ### AWS CLI ###
# ###############
# pip install awscli --upgrade
# cat << EOS >> ~/.zshrc
# # for aws completion
# source $(pyenv root)/versions/${PYTHON_VERSION}/bin/aws_zsh_completer.sh

# EOS

# ###################
# ### AWS SAM CLI ###
# ###################
# pip install aws-sam-cli --upgrade

# ##########################
# ### CodeBuild on local ###
# ##########################
# sudo apt install -y \
# 	jq
# AWS_CODEBUILD_DOCKER_IMAGES_REPO="aws/aws-codebuild-docker-images"
# git clone --depth 1 \
# 	-b $(curl -s https://api.github.com/repos/${AWS_CODEBUILD_DOCKER_IMAGES_REPO}/releases/latest | jq -r '.tag_name') \
# 	https://github.com/${AWS_CODEBUILD_DOCKER_IMAGES_REPO}.git \
# 	~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}
# cat << EOS >> ~/.zshrc
# # for building codebuild image
# # \$1: build language environment
# # \$2: version
# # ex) codebuildimage python 3.7.1
# codebuildimage () {
#   docker build -t aws/codebuild/\$1:\$2 ~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}/ubuntu/\$1/\$2
# }

# EOS
# sudo docker pull amazon/aws-codebuild-local:latest --disable-content-trust=false
# sudo chown -R $USER:docker ~/.docker
# cat << EOS >> ~/.zshrc
# # for executing codebuild on local
# # \$1: build language environment
# # \$2: version
# # \$3: output dir for artifact
# # \$4: optional parameters (details in below url)
# # ex) codebuildimage python 3.7.1 . -b buildspec.yaml
# # for more details
# # https://github.com/aws/aws-codebuild-docker-images/tree/master/local_builds
# codebuildexec () {
# 	~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}/local_builds/codebuild_build.sh \
# 		-i aws/codebuild/\$1:\$2 \
# 		-a \$3 \
# 		-s . "\$@"
# }

# EOS

# #############
# ### react ###
# #############
# source ~/.zshrc
# yarn global add create-react-app
# cat << EOS >> ~/.zshrc
# # for react-script to detect source code changes
# export CHOKIDAR_USEPOLLING=true

# EOS


# # npm install -g json-server
# # apt install -y redis-tools

sudo apt autoremove
