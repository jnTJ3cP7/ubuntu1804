#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
if ! which anyenv >/dev/null; then
	echo 'please provision anyenv before python provision'
	exit 1
fi

if which pyenv >/dev/null; then
	anyenv update -f pyenv
else
	sudo apt update -y && \
		sudo apt install -y \
			zlib1g-dev \
			libssl-dev \
			libffi-dev \
			libbz2-dev \
			libreadline-dev \
			libsqlite3-dev && \
		sudo apt autoremove -y
	if [ $? -ne 0 ]; then
		echo 'exit because must liblaries install failed'
		exit 1
	fi

	anyenv install pyenv
	source ~/.zshrc 2>/dev/null
fi

PYTHON_VERSION=$(curl -s https://www.python.org/downloads/ | sed -n 's/^.*<a class="button" .*href="https.*\.tar\.xz".*>Download Python \([^\/]\+\)<\/a>.*$/\1/p')

PYENV_VERSIONS=$(pyenv versions)
if [[ $(echo $PYENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $PYTHON_VERSION ]]; then
	if ! echo $PYENV_VERSIONS | egrep -q "^  $PYTHON_VERSION$"; then
		pyenv install $PYTHON_VERSION
	fi
	pyenv global $PYTHON_VERSION
fi
pip install --upgrade pip pipenv
