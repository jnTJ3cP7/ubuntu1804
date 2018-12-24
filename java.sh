#!/bin/bash

sudo apt update
sudo apt install -y openjdk-8-jdk

JAVA8_PATH=$(dpkg -L openjdk-8-jdk | sed -n 's/^\(.*\)\/bin$/\1/gp')
JAVA8_VERSION=$(eval $(echo "${JAVA8_PATH}/bin/java -version") 2>&1 1>/dev/null | head -1 | cut -d" " -f 3 | sed 's/"\(.*\)"/\1/g' | tr _ .)

# for anyenv path import
source ~/.zshrc 2>/dev/null
which jenv
if [ $? -ne 0 ] ;then
  anyenv install jenv
  source ~/.zshrc 2>/dev/null
fi

jenv versions | awk '{print $1}' | grep -q $JAVA8_VERSION
if [ $? -ne 0 ] ;then
  jenv add $JAVA8_PATH 
fi

jenv global $JAVA8_VERSION
