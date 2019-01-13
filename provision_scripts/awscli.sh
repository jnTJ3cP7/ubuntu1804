#!/bin/zsh

###################################################
# This provision script depends on below provisions
#   - python
###################################################
source ~/.zshrc 2>/dev/null
! which pyenv >/dev/null && echo 'please provision python before awscli provision' && exit 1

pip install awscli --upgrade || {echo 'awscli install failed' && exit 1}

AWS_ZSH_COMPLETER="$(pyenv root)/versions/$(pyenv version | awk '{print $1}')/bin/aws_zsh_completer.sh"
if ! fgrep -q "$AWS_ZSH_COMPLETER" ~/.zshrc; then
  cat << EOS >> ~/.zshrc
# for aws completion
source $AWS_ZSH_COMPLETER

EOS
fi

# for AWS SAM CLI
pip install aws-sam-cli --upgrade || {echo 'aws-sam-cli install failed' && exit 1}
