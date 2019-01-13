#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
! which anyenv >/dev/null && echo 'please provision anyenv before java provision' && exit 1

# Must change way of install and patch vresion management after amazon java is released in ubuntu
(sudo apt update -y && sudo apt install -y openjdk-8-jdk) || {echo 'openjdk-8-jdk install failed' && exit 1}
sudo apt autoremove -y

if which jenv >/dev/null; then
	anyenv update -f jenv
else
  anyenv install jenv || {echo 'jenv install failed' && exit 1}
  source ~/.zshrc 2>/dev/null
fi

JAVA8_PATH=$(dpkg -L openjdk-8-jdk | sed -n 's/^\(.*\)\/bin$/\1/gp')
JAVA8_VERSION=$(eval $(echo "${JAVA8_PATH}/bin/java -version") 2>&1 1>/dev/null | head -1 | cut -d" " -f 3 | sed 's/"\(.*\)"/\1/g' | tr _ .)

JENV_VERSIONS=$(jenv versions)
if [[ $(echo $JENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $JAVA8_VERSION ]]; then
	if ! echo $JENV_VERSIONS | egrep -q "^  $JAVA8_VERSION$"; then
		jenv add $JAVA8_PATH || {echo "jenv add [ $JAVA8_PATH ] failed" && exit 1}
	fi
	jenv global $JAVA8_VERSION || {echo "jenv global [ $JAVA8_VERSION ] failed" && exit 1}
fi
