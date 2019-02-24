#!/bin/zsh

ANYENV_DIR=${HOME}/.anyenv
if [ -d ${ANYENV_DIR}/.git ]; then
	git -C $ANYENV_DIR pull --no-tags origin master
else
	rm -rf $ANYENV_DIR
	git clone --depth 1 https://github.com/anyenv/anyenv $ANYENV_DIR
fi
[ $? -eq 0 ] || {echo 'anyenv install or update failed' && exit 1}

ANYENV_INIT_CMD='eval "$(anyenv init -)"'
# TODO may be better to change from .zshrc to .zshenv
if ! fgrep -q "$ANYENV_INIT_CMD" ~/.zshrc; then
	cat << EOS >> ~/.zshrc
# for anyenv
export PATH="${ANYENV_DIR}/bin:\$PATH"
$ANYENV_INIT_CMD

EOS
fi

source ~/.zshrc 2>/dev/null

if [ -d ~/.config/anyenv/anyenv-install/.git ]; then
	anyenv install --force-init
fi
anyenv install --update

ANYENV_PLUGINS_DIR=$(anyenv root)/plugins
ANYENV_UPDATE_DIR=${ANYENV_PLUGINS_DIR}/anyenv-update
if [ -d ${ANYENV_UPDATE_DIR}/.git ]; then
	git -C $ANYENV_UPDATE_DIR pull --no-tags origin master
else
	mkdir -p $ANYENV_PLUGINS_DIR
	rm -rf $ANYENV_UPDATE_DIR
	git clone --depth 1 https://github.com/znz/anyenv-update.git $ANYENV_UPDATE_DIR
fi
[ $? -eq 0 ] || {echo 'anyenv-update install or update failed' && exit 1}
