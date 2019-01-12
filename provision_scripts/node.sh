#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
if ! which anyenv >/dev/null; then
	echo 'please provision anyenv before node provision'
	exit 1
fi

if which ndenv >/dev/null; then
	anyenv update -f ndenv
else
	anyenv install ndenv
	source ~/.zshrc 2>/dev/null
fi

if ! [ -d "$(ndenv root)/plugins/ndenv-yarn-install/.git" ]; then
	git clone --depth 1 https://github.com/pine/ndenv-yarn-install.git "$(ndenv root)/plugins/ndenv-yarn-install"
	source ~/.zshrc 2>/dev/null
fi

NODE_VERSION=$(curl -s https://nodejs.org/en/ | sed -n 's/^.*title="Download \([^\/]\+\) LTS".*$/\1/p')

NDENV_VERSIONS=$(ndenv versions)
if [[ $(echo $NDENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $NODE_VERSION ]]; then
	if ! echo $NDENV_VERSIONS | egrep -q "^  $NODE_VERSION$"; then
		ndenv install $NODE_VERSION
	fi
	OLD_ADDED_ZSHRC_SCRIPT="# for yarn global installed packages\nexport PATH=\"$(yarn global bin):\$PATH\"\n" 2>/dev/null
	START_LINE_NUMBER=$(echo '# for yarn global installed packages' | head -1 | xargs -i awk "/{}/{print NR}" ${HOME}/.zshrc)
	END_LINE_NUMBER=$[${START_LINE_NUMBER}+$(echo $OLD_ADDED_ZSHRC_SCRIPT | wc -l)-1]
	sed -i "${START_LINE_NUMBER},${END_LINE_NUMBER}d" ~/.zshrc

	ndenv global $NODE_VERSION
	NEW_ADDED_ZSHRC_SCRIPT="# for yarn global installed packages\nexport PATH=\"$(yarn global bin):\$PATH\"\n"
	echo $NEW_ADDED_ZSHRC_SCRIPT >> ~/.zshrc
fi
