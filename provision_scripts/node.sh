#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
! which anyenv >/dev/null && echo 'please provision anyenv before node provision' && exit 1

# TODO Must change ndenv into nodenv
if which ndenv >/dev/null; then
	anyenv update -f ndenv
else
	anyenv install ndenv || {echo 'ndenv install failed' && exit 1}
	source ~/.zshrc 2>/dev/null
fi

YARN_PLUGIN_DIR=$(ndenv root)/plugins/ndenv-yarn-install
if ! [ -d ${YARN_PLUGIN_DIR}/.git ]; then
	rm -rf $YARN_PLUGIN_DIR
	git clone --depth 1 https://github.com/pine/ndenv-yarn-install.git $YARN_PLUGIN_DIR || \
		{echo 'yarn plugin repository clone failed' && exit 1}
	source ~/.zshrc 2>/dev/null
fi

NODE_VERSION=$(curl -s https://nodejs.org/en/ | sed -n 's/^.*title="Download \([^\/]\+\) LTS".*$/\1/p')

NDENV_VERSIONS=$(ndenv versions)
if [[ $(echo $NDENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $NODE_VERSION ]]; then
	if ! echo $NDENV_VERSIONS | egrep -q "^  $NODE_VERSION$"; then
		ndenv install $NODE_VERSION || {echo "ndenv install [ $NODE_VERSION ] failed" && exit 1}
	fi
	OLD_ADDED_ZSHRC_SCRIPT="# for yarn global installed packages\nexport PATH=\"$(yarn global bin):\$PATH\"\n" 2>/dev/null
	START_LINE_NUMBER=$(echo $OLD_ADDED_ZSHRC_SCRIPT | head -1 | xargs -i awk "/{}/{print NR}" ${HOME}/.zshrc)
	if [[ $START_LINE_NUMBER =~ ^[1-9][0-9]*$ ]]; then
		END_LINE_NUMBER=$[${START_LINE_NUMBER}+$(echo $OLD_ADDED_ZSHRC_SCRIPT | wc -l)-1]
		sed -i "${START_LINE_NUMBER},${END_LINE_NUMBER}d" ~/.zshrc
	fi

	ndenv global $NODE_VERSION || {echo "ndenv global [ $NODE_VERSION ] failed" && exit 1}
	NEW_ADDED_ZSHRC_SCRIPT="# for yarn global installed packages\nexport PATH=\"$(yarn global bin):\$PATH\"\n"
	echo $NEW_ADDED_ZSHRC_SCRIPT >> ~/.zshrc
fi
