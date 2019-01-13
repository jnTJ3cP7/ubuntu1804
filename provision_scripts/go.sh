#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
! which anyenv >/dev/null && echo 'please provision anyenv before go provision' && exit 1

if which goenv >/dev/null; then
	anyenv update -f goenv
else
	anyenv install goenv || {echo 'goenv install failed' && exit 1}
	source ~/.zshrc 2>/dev/null
fi


GO_VERSION=$(curl -s https://golang.org/dl/ | sed -n 's/^.*<a class=".*downloadBox.*" .*href="https.*go\([^\/]\+\)\.src\.tar\.gz".*$/\1/p')

GOENV_VERSIONS=$(goenv versions)
if [[ $(echo $GOENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $GO_VERSION ]]; then
	if ! echo $GOENV_VERSIONS | egrep -q "^  $GO_VERSION$"; then
		goenv install $GO_VERSION || {echo "goenv install [ $GO_VERSION ] failed" && exit 1}
	fi
	goenv global $GO_VERSION || {echo "goenv global [ $GO_VERSION ] failed" && exit 1}
fi
