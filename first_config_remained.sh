#!/bin/bash

source ~/.zshrc

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

# npm install -g json-server
# apt install -y redis-tools

sudo apt autoremove -y
