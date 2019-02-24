#!/bin/zsh

# params check
# arg 1 is Personal Access Token for code-settings-sync
# arg 2 is Gist ID for code-settings-sync
case $# in
	0)
		echo 'Personal Access Token and Gist ID are not specified'
		exit 1
		;;
	1)
		echo 'Personal Access Token or Gist ID is not specified'
		exit 1
		;;
	2)
		PERSONAL_ACCESS_TOKEN=$1
		GIST_ID=$2
		;;
	*)
		echo 'Unexpected params exist'
		exit 1
		;;
esac

REPO='https://packages.microsoft.com/repos/vscode'
if ! sudo sh -c "fgrep -q $REPO /etc/apt/sources.list.d/vscode.list"; then
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
	rm microsoft.gpg
	sudo sh -c "echo \"deb [arch=amd64] $REPO stable main\" > /etc/apt/sources.list.d/vscode.list"
	sudo apt install -y apt-transport-https
fi
sudo apt update -y
sudo apt install -y code
sudo apt autoremove

code --force --install-extension shan.code-settings-sync
if ! grep -q "\"token\":\"$PERSONAL_ACCESS_TOKEN\"" ~/.config/Code/User/syncLocalSettings.json; then
  echo "{\"token\":\"$PERSONAL_ACCESS_TOKEN\"}" > ~/.config/Code/User/syncLocalSettings.json
fi
if egrep -q '"sync\.gist": ".+"' ~/.config/Code/User/settings.json; then
	sed -i "s/\"sync\.gist\": \".\+\"/\"sync\.gist\": \"$GIST_ID\"/g" ~/.config/Code/User/settings.json
else
	cat << EOS > ~/.config/Code/User/settings.json
{
    "sync.gist": "$GIST_ID"
}
EOS
fi
