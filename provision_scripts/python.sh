#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - anyenv
###################################################
source ~/.zshrc 2>/dev/null
! which anyenv >/dev/null && echo 'please provision anyenv before python provision' && exit 1

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
			libsqlite3-dev
	if [ $? -ne 0 ]; then
		echo 'exit because must liblaries install failed'
		exit 1
	fi
	sudo apt autoremove -y

	anyenv install pyenv || {echo 'pyenv install failed' && exit 1}
	source ~/.zshrc 2>/dev/null
fi

PYTHON_VERSION=$(curl -s https://www.python.org/downloads/ | sed -n 's/^.*<a class="button" .*href="https.*\.tar\.xz".*>Download Python \([^\/]\+\)<\/a>.*$/\1/p')

PYENV_VERSIONS=$(pyenv versions)
if [[ $(echo $PYENV_VERSIONS | sed -n 's/^\* \([^ ]\+\) .*$/\1/p') != $PYTHON_VERSION ]]; then
	if ! echo $PYENV_VERSIONS | egrep -q "^  $PYTHON_VERSION$"; then
		pyenv install $PYTHON_VERSION || {echo "pyenv install [ $PYTHON_VERSION ] failed" && exit 1}
	fi
	pyenv global $PYTHON_VERSION || {echo "pyenv global [ $PYTHON_VERSION ] failed" && exit 1}
fi

pip install --upgrade pip pipenv flake8 autopep8 isort || {echo '`pip install --upgrade` failed' && exit 1}

if ! fgrep -q 'PIPENV_VENV_IN_PROJECT' ~/.zshrc; then
	cat << EOS >> ~/.zshrc
# for creating venv dir of pipenv
export PIPENV_VENV_IN_PROJECT=true

EOS
fi

###################################################
# This provision script affects below provisions
#   - awscli
#   - docker
###################################################
