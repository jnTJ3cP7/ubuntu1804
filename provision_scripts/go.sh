#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
if ! which anyenv >/dev/null; then
	echo 'please provision anyenv before go provision'
	exit 1
fi

if which goenv >/dev/null; then
	anyenv update -f goenv
else
	anyenv install goenv
	source ~/.zshrc 2>/dev/null
fi


GO_VERSION=$(curl -s https://golang.org/dl/ | sed -n 's/^.*<a class=".*downloadBox.*" .*href="https.*go\([^\/]\+\)\.src\.tar\.gz".*$/\1/p')

GOENV_VERSIONS=$(goenv versions)
if [[ $(echo $GOENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $GO_VERSION ]]; then
	if ! echo $GOENV_VERSIONS | egrep -q "^  $GO_VERSION$"; then
		goenv install $GO_VERSION
	fi
	goenv global $GO_VERSION
fi
