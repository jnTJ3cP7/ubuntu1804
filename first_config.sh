#!/bin/bash

# params check
# arg 1 is USER on vagrant operation
case $# in
	0)
		echo 'USER NAME is not specified'
		exit 1
		;;
	1)
		USER_NAME=$1
		echo "Guest user is [ $USER_NAME ]"
		;;
	*)
		echo 'Unexpected params exist'
		exit 1
		;;
esac

sudo apt update -y
sudo apt full-upgrade -y

sudo update-locale LC_ALL=C.UTF-8
sudo timedatectl set-timezone Asia/Tokyo

###########
### Zsh ###
###########
sudo apt install -y \
	curl \
	zsh
curl -OL https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh
echo -e "vagrant" | sh install.sh
rm -f install.sh
git clone --depth 1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
cat << EOS >> ~/.zshrc

# for zsh-completions
plugins=(… zsh-completions)
autoload -U compinit && compinit

EOS

##############
### anyenv ###
##############
git clone --depth 1 https://github.com/riywo/anyenv ~/.anyenv
cat << 'EOS' >> ~/.zshrc
# for anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

EOS
source ~/.zshrc 2>/dev/null
mkdir -p $(anyenv root)/plugins
git clone --depth 1 https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
sudo apt install -y \
	zlib1g-dev \
	libssl-dev \
	libffi-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev
anyenv install pyenv
anyenv install ndenv
anyenv install goenv
source ~/.zshrc 2>/dev/null
PYTHON_VERSION="3.7.1"
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
pip install --upgrade pip
pip install pipenv --upgrade
git clone --depth 1 https://github.com/pine/ndenv-yarn-install.git "$(ndenv root)/plugins/ndenv-yarn-install"
source ~/.zshrc 2>/dev/null
NODE_VERSION="v10.14.2"
ndenv install $NODE_VERSION
ndenv global $NODE_VERSION
cat << EOS >> ~/.zshrc
# for yarn global installed packages
export PATH="$(yarn global bin):\$PATH"

EOS

##############
### Docker ###
##############
sudo apt install -y \
	apt-transport-https \
	ca-certificates \
	software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
sudo apt update
sudo apt install -y docker-ce
sudo gpasswd -a $USER docker
pip install docker-compose --upgrade
sudo systemctl restart docker.service

###############
### AWS CLI ###
###############
pip install awscli --upgrade
cat << EOS >> ~/.zshrc
# for aws completion
source $(pyenv root)/versions/${PYTHON_VERSION}/bin/aws_zsh_completer.sh

EOS

###################
### AWS SAM CLI ###
###################
pip install aws-sam-cli --upgrade

##########################
### CodeBuild on local ###
##########################
sudo apt install -y \
	jq
AWS_CODEBUILD_DOCKER_IMAGES_REPO="aws/aws-codebuild-docker-images"
git clone --depth 1 \
	-b $(curl -s https://api.github.com/repos/${AWS_CODEBUILD_DOCKER_IMAGES_REPO}/releases/latest | jq -r '.tag_name') \
	https://github.com/${AWS_CODEBUILD_DOCKER_IMAGES_REPO}.git \
	~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}
cat << EOS >> ~/.zshrc
# for building codebuild image
# \$1: build language environment
# \$2: version
# ex) codebuildimage python 3.7.1
codebuildimage () {
  docker build -t aws/codebuild/\$1:\$2 ~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}/ubuntu/\$1/\$2
}

EOS
sudo docker pull amazon/aws-codebuild-local:latest --disable-content-trust=false
sudo chown -R $USER:docker ~/.docker
cat << EOS >> ~/.zshrc
# for executing codebuild on local
# \$1: build language environment
# \$2: version
# \$3: output dir for artifact
# \$4: optional parameters (details in below url)
# ex) codebuildimage python 3.7.1 . -b buildspec.yaml
# for more details
# https://github.com/aws/aws-codebuild-docker-images/tree/master/local_builds
codebuildexec () {
	~/.${AWS_CODEBUILD_DOCKER_IMAGES_REPO#*/}/local_builds/codebuild_build.sh \
		-i aws/codebuild/\$1:\$2 \
		-a \$3 \
		-s . "\$@"
}

EOS

#############
### react ###
#############
source ~/.zshrc
yarn global add create-react-app
cat << EOS >> ~/.zshrc
# for react-script to detect source code changes
export CHOKIDAR_USEPOLLING=true

EOS


# npm install -g json-server
# apt install -y redis-tools

sudo apt install -y lubuntu-desktop
# sudo apt install -y gnome-session-flashback


sudo apt autoremove
