#!/bin/zsh

##############
### anyenv ###
##############
source ~/.zshrc 2>/dev/null
if ! which anyenv; then
	git clone --depth 1 https://github.com/riywo/anyenv ~/.anyenv
	cat << 'EOS' >> ~/.zshrc
# for anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

EOS
source ~/.zshrc 2>/dev/null
fi

if ! [ -d $(anyenv root)/plugins/anyenv-update/.git ]; then
	mkdir -p $(anyenv root)/plugins
	git clone --depth 1 https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
fi
