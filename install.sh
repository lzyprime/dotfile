#!/bin/bash
set -e

function install_oh_my_bash() {
	bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

	## 主题换行
	local theme_file="$HOME/.oh-my-bash/themes/font/font.theme.sh"
	sed -i "s@\${ret_status}@\${ret_status}\\\n@g" "$theme_file"
}
function install_oh_my_zsh() {
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

function install_primerc() {
	for file in ".bashrc" ".zshrc"; do
		if [ -f "$HOME/$file" ]; then
			echo "set primerc to $HOME/$file"
			sed -i "/primerc/d" "$HOME/$file" || true
			echo "source '$(dirname "$0")/primerc'" | tee -a "$HOME/$file"
		fi
	done
}

declare -A install_desc=(
[install_oh_my_bash]="安装 oh-my-bash"
[install_oh_my_zsh]="安装 oh-my-zsh"
[install_primerc]="设置 primerc 到 .bashrc 和 .zshrc"
[auto_install]="自动执行所有安装"
)

function run_func() {
	local func="$1"
	echo "--- ${install_desc[$func]} start ---"
	if "$func"; then echo "--- ${install_desc[$func]} Success ---"; else echo "--- ${install_desc[$func]} Fail ---"; fi
}

function auto_install() {
	for func in "${!install_desc[@]}"; do
		[[ "$func" != install_* ]] && continue
		run_func "$func"
	done
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
