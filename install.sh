#!/bin/bash
set -e

DOTFILE_DIR="$(dirname "$(realpath "$0")")"

declare -A pkg_homepage_url=(
	[wps]='https://www.wps.cn/product/wpslinux'
	[vscode]='https://packages.microsoft.com/repos/code/pool/main/c/code/'
	[clash-verge]='https://github.com/clash-verge-rev/clash-verge-rev/releases/'
	[go]='https://go.dev/dl'
	[tg]='https://td.telegram.org/tlinux/'
	[qq]='https://im.qq.com'
)
declare -A pkg_latest=(
	[wps]='https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25838/wps-office_12.1.2.25838.AK.preread.sw_648473_amd64.deb?t=1775703352&k=2a1bfd02a45a2d4a6d4293e525130acf'
	[vscode_amd64]='https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.115.0-1775600353_amd64.deb'
	[vscode_arm64]='https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.99.3-1744760597_arm64.deb'
	[clash]='https://github.com/clash-verge-rev/clash-verge-rev/releases/download/v2.4.7/Clash.Verge_2.4.7_amd64.deb'
	[tg]='https://td.telegram.org/tlinux/tsetup.6.6.2.tar.xz'
	[qq]='https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.27_260401_amd64_01.deb'
)

function show-latest() {
	for pkg in "${!pkg_homepage_url[@]}"; do
		echo "-------- $pkg -------"
		echo "homepage: ${pkg_homepage_url[$pkg]}"
		echo "download: ${pkg_latest[$pkg]}"
	done
}

install_func=('ombash')
function ombash() {
	bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

	## 主题换行
	local theme_file="$HOME/.oh-my-bash/themes/font/font.theme.sh"
	sed -i 's@\\W@\\w@g' "$theme_file"
	sed -i "s@\${ret_status}@\${ret_status}\\\n@g" "$theme_file"
}

install_func+=('omzsh')
function omzsh() {
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_func+=(opencode)
function opencode() {
    curl -fsSL https://opencode.ai/install | bash
    configdir="$HOME/.config/opencode/"
    set -x
    mkdir -p "$configdir"
    cp "$DOTFILE_DIR/opencode.json" "$configdir"
    set +x
}

install_func+=(primerc)
function primerc() {
	ln -sf "$DOTFILE_DIR/primerc" "$HOME/.primerc"
	for file in ".bashrc" ".zshrc"; do
		if [ -f "$HOME/$file" ]; then
			echo "set primerc to $HOME/$file"
			sed -i "/primerc/d" "$HOME/$file" || true
			echo "source '$HOME/.primerc'" | tee -a "$HOME/$file"
		fi
	done
}


install_func+=(vscode)
function vscode() {
	wget -O vscode.deb "${pkg_latest[vscode_$(dpkg --print-architecture)]}"
	sudo apt install ./vscode.deb
}

install_func+=(clash-verge-rev)
function clash-verge-rev() {
	wget -O clash.deb "${pkg_latest[clash]}"
	sudo apt install ./clash.deb
}

install_func+=(tg)
function tg() {
	wget -O TG.tar.xz "${pkg_latest[tg]}"
	tar xJf TG.tar.xz -C "$HOME/.local/share/"
	"$HOME/.local/share/Telegram/Telegram"
}

install_func+=(go)
function go() {
	wget -O go.tar.gz "${pkg_latest[go]}"
	tar xzf go.tar.gz -C "$HOME/.local"
}

install_func+=(oembuild)
function oembuild() {
	set -x
	sudo mkdir -p /usr/local/bin/
	sudo ln -sf "$DOTFILE_DIR/oembuild" /usr/local/bin/oembuild
	sudo chmod +x /usr/local/bin/oembuild
	set +x
}

install_func+=(add_to_sudonopasswd)
function add_to_sudonopasswd() {
	if grep '%sudonopasswd' /etc/sudoers; then
		sudo sed '/%sudo /a%sudonopasswd   ALL=(ALL:ALL) NOPASSWD:ALL' /etc/sudoers
		sudo groupadd sudonopasswd
	fi
	sudo usermod -aG sudonopasswd "$USER"
}

install_func+=(firefox)
function firefox() {
	bash "$DOTFILE_DIR/install-firefox-from-apt.sh"
}


install_func+=(qq)
function qq() {
	wget -O qq.deb "${pkg_latest[qq]}"
	ls -al qq.deb
	sudo apt install ./qq.deb
}

install_func+=(weixin)
function weixin() {
	wget -O weixin.deb 'https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb'
	ls -al weixin.deb
	sudo apt install ./weixin.deb
}

declare -A install_desc=(
[ombash]="安装 oh-my-bash"
[omzsh]="安装 oh-my-zsh"
[primerc]="设置 primerc 到 .bashrc 和 .zshrc"
[vscode]='安装 vscode'
[opencode]='安装 opencode terminal'
[go]='安装 go'
[tg]='安装 telegram'
[oembuild]='安装 oembuild'
[clash-verge-rev]='安装 clash-verge-rev'
[add_to_sudonopasswd]='配置 sudo 免密'
[firefox]="安装 firefox"
[qq]="安装 qq"
[weixin]="安装 weixin"
[auto_install]="自动执行所有安装, ${install_func[@]}"
[show-latest]="展示软件包官网最新下载地址"
)

function run_func() {
	local func="$1"
	echo "--- ${install_desc[$func]} start ---"
	if "$func"; then 
		echo "--- ${install_desc[$func]} Success ---"
	else 
		echo "--- ${install_desc[$func]} Fail ---"
		return 1
	fi
}

function auto_install() {
	local failed_func=()
	for func in "${install_func[@]}"; do
		if ! run_func "$func"; then
			failed_func+=("$func: ${install_desc[$func]}")
		fi
	done
	if [ "${#failed_func[@]}" != 0 ]; then 
		echo "------- failed: --------"
		for l in "${failed_func[@]}"; do
			echo "$l"
		done
		echo "------------------------"
	fi
	return "${#failed_func[@]}"
}

function help() {
	echo "$0 function_name"
	echo ""

	{
	echo "function_name@description"
	echo "----- @ -----"
	for func in "${install_func[@]}"; do
		echo "${func}@${install_desc[$func]:-"$func"}"
	done
	} | column -t -s '@'
}

if [ "${1:-help}" = help ]; then 
	help
else
	run_func "${1}"
fi
