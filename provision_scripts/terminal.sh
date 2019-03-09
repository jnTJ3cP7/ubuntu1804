#!/bin/zsh

install_patched_fonts () {
	nerd_fonts_dir="$1"
	if [ ! "$nerd_fonts_dir" ]; then
		echo 'Must be specify `nerd_fonts_dir` as first arg on `install_patched_fonts` function'
		exit 1
	fi
	patched_fonts="$2"
	if [ ! "$patched_fonts" ]; then
		echo 'Must be specify `patched_fonts` as first arg on `install_patched_fonts` function'
		exit 1
	fi
	now_dir=`pwd`
	cd $1
	./install.sh $2; cd $now_dir
}

ICON_REPO='ryanoasis/nerd-fonts'
NERD_FONTS_LATEST_VERSION=$(curl -s https://api.github.com/repos/${ICON_REPO}/releases/latest | jq -r '.tag_name')
NERD_FONTS_DIR=${HOME}/.${ICON_REPO#*/}
NEED_INSTALLATION=true
if [ -d ${NERD_FONTS_DIR}/.git ]; then
	if [ $(git -C $NERD_FONTS_DIR show-ref --tags | awk -F\/ '{print $NF}') != $NERD_FONTS_LATEST_VERSION ]; then
		git -C $NERD_FONTS_DIR fetch --depth 1 origin refs/tags/${NERD_FONTS_LATEST_VERSION}:refs/tags/$NERD_FONTS_LATEST_VERSION
		git -C $NERD_FONTS_DIR checkout $NERD_FONTS_LATEST_VERSION || {echo "nerd-fonts latest version [ $NERD_FONTS_LATEST_VERSION ] checkout failed" && exit 1}
	else
		NEED_INSTALLATION=false
	fi
else
	rm -rf $NERD_FONTS_DIR
	git clone --depth 1 -b $NERD_FONTS_LATEST_VERSION https://github.com/${ICON_REPO}.git $NERD_FONTS_DIR || {echo 'nerd-fonts clone failed' && exit 1}
fi

if "$NEED_INSTALLATION"; then
	install_patched_fonts $NERD_FONTS_DIR FiraCode
fi

HYPER_REPO='zeit/hyper'
# TODO Need to change way to get latest version after v3 stable version released
HYPER_VERSION='3.0.0-canary.8'
HYPER_DEB="hyper_${HYPER_VERSION}_amd64.deb"
curl -LO https://github.com/${HYPER_REPO}/releases/download/${HYPER_VERSION}/$HYPER_DEB

sudo dpkg -i $HYPER_DEB && rm -f $HYPER_DEB

HYPER_CONFIG=${HOME}/.hyper.js
curl -Lo $HYPER_CONFIG https://github.com/${HYPER_REPO}/raw/${HYPER_VERSION}/app/config/config-default.js

# TODO Delete this settings after v3 stable version released
sed -i "s/updateChannel: '.*'/updateChannel: 'canary'/g" $HYPER_CONFIG
# fonts
FONT='FuraCode Nerd Font'
# TODO not need to execute command when version not updated after v3 stable version released because config file is not updated
sed -i "s/fontFamily: '\(.*\)'/fontFamily: '\"$FONT\", \1'/g" $HYPER_CONFIG
# plugins
sed -i "s/plugins: \[.*\]/plugins: ['hyper-material-theme', 'hyperterm-paste']/g" $HYPER_CONFIG

PREZTO_CONFIG=${HOME}/.zpreztorc
NOW_THEME_INFO=$(grep -n '^zstyle \(.*\) theme .*$' $PREZTO_CONFIG)
if [ $(echo $NOW_THEME_INFO | wc -l) -ne 1 ]; then
	echo "Unexpected lines exist in $PREZTO_CONFIG"
	exit 1
fi
THEME='pure'
sed -i "s/^zstyle \(.*\) theme .*$/zstyle \1 theme '$THEME'/g" $PREZTO_CONFIG
line_num=$(echo $NOW_THEME_INFO | awk -F: '{print $1}')

ADDED_MODULES=('syntax-highlighting' 'autosuggestions')
for m in ${ADDED_MODULES[@]}; do
	if ! fgrep -q "'$m' \\" $PREZTO_CONFIG; then
		sed -i "/'prompt'/ i\  '$m' \\\\" $PREZTO_CONFIG
	fi
done
