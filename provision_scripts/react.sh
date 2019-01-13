#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - node
###################################################
source ~/.zshrc 2>/dev/null
! which ndenv >/dev/null && echo 'please provision node before react provision' && exit 1

yarn global add create-react-app || {echo 'create-react-app install failed' && exit 1}

if ! fgrep -q 'CHOKIDAR_USEPOLLING' ~/.zshrc; then
	cat << EOS >> ~/.zshrc
# for react-script to detect source code changes
export CHOKIDAR_USEPOLLING=true

EOS
fi
