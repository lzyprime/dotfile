#!/bin/bash
set -e

install_func=('install_ombash')
function install_ombash() {
	bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

	## 主题换行
	local theme_file="$HOME/.oh-my-bash/themes/font/font.theme.sh"
	sed -i 's@\\W@\\w@g' "$theme_file"
	sed -i "s@\${ret_status}@\${ret_status}\\\n@g" "$theme_file"
}
install_func+=('install_omzsh')
function install_omzsh() {
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_func+=('install_primerc')
function install_primerc() {
	for file in ".bashrc" ".zshrc"; do
		if [ -f "$HOME/$file" ]; then
			echo "set primerc to $HOME/$file"
			sed -i "/primerc/d" "$HOME/$file" || true
			echo "source '$(dirname "$(realpath "$0")")/primerc'" | tee -a "$HOME/$file"
		fi
	done
}


install_func+=(install_vscode)
function install_vscode() {
	declare -A ar_deb_mp=(
		[amd64]='https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.99.3-1744761595_amd64.deb'
		[arm64]='https://packages.microsoft.com/repos/code/pool/main/c/code/code_1.99.3-1744760597_arm64.deb'
	)
	wget -O vscode.deb "${ar_deb_mp[$(dpkg --print-architecture)]}"
	sudo apt install ./vscode.deb
}

install_func+=(install_tg)
function install_tg() {
	wget -o TG.tar.xz https://td.telegram.org/tlinux/tsetup.6.6.2.tar.xz
	tar xJf TG.tar.xz -C "$HOME/.local/share/"
	"$HOME/.local/share/Telegram/Telegram"
}

install_func+=(download_pkg)
function download_pkg() {
	echo "wps: https://www.wps.cn/product/wpslinux"
	echo ""
}

declare -A install_desc=(
[install_ombash]="安装 oh-my-bash"
[install_omzsh]="安装 oh-my-zsh"
[install_primerc]="设置 primerc 到 .bashrc 和 .zshrc"
[install_vscode]='安装 vscode'
[download_pkg]='下载最新软件包'
[auto_install]="自动执行所有安装, ${install_func[@]}"
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
	for func in "${!install_desc[@]}"; do
		echo "${func}@${install_desc[$func]}"
	done
	} | column -t -s '@'
}

"${1:-help}"
