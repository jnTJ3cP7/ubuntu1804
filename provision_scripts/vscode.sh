#!/bin/zsh

# params check
# arg 1 is Personal Access Token for code-settings-sync
case $# in
	0)
		echo 'Personal Access Token is not specified'
		exit 1
		;;
	1)
		PERSONAL_ACCESS_TOKEN=$1
		;;
	*)
		echo 'Unexpected params exist'
		exit 1
		;;
esac

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
rm microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt install -y apt-transport-https
sudo apt update -y
sudo apt install -y code

code --force --install-extension vscodevim.vim
code --force --install-extension robertohuertasm.vscode-icons
code --force --install-extension mde.select-highlight-minimap
code --force --install-extension eamodio.gitlens
code --force --install-extension ms-vscode.go
code --force --install-extension shan.code-settings-sync
if ! grep -q "\"token\":\"$PERSONAL_ACCESS_TOKEN\"" ~/.config/Code/User/syncLocalSettings.json; then
  echo "{\"token\":\"$PERSONAL_ACCESS_TOKEN\"}" > ~/.config/Code/User/syncLocalSettings.json
fi
