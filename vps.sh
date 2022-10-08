#!/usr/bin/env bash
#
# Copyright (c) 2022 arbalest
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/arbaleast/aria2.sh
# Description: 
# System Required: CentOS/Debian/Ubuntu
# Version: 1.0.0

sh_ver="1.0.0"
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/sbin:/bin

# text color
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"

# log display
Info="[${Green_font_prefix}INFO${Font_color_suffix}]"
Error="[${Red_font_prefix}ERROR${Font_color_suffix}]"
Tip="[${Green_font_prefix}NOTICE${Font_color_suffix}]"


###############################################################
# check root permission
check_root() {
    [[ $EUID != 0 ]] && echo -e "${Error} this account is not Adminstrator account(or no root permission), cannot exec continue, Pleaese use root account or use ${Green_background_prefix}sudo su${Font_color_suffix} commadn to get temp root permission(maybe need current account password)" && exit 1
}
# check system type
check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    ARCH=$(uname -m)
    [ $(command -v dpkg) ] && dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
}

install_tools() {
    apt update && apt upgrade -y
    apt install -y vim git zsh language-pack-zh-hans curl socat htop

    echo "LANG="zh_CN.UTF-8"" >> /etc/profile

    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install

    # config vim
    mkdir -p ~/.vim/pack/git-plugins/start

    git clone --depth 1 https://github.com/dense-analysis/ale.git ~/.vim/pack/git-plugins/start/ale
    git clone https://github.com/pedrohdz/vim-yaml-folds.git ~/.vim/plugged/vim-yaml-folds
    git clone https://github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLine
    git clone https://github.com/NLKNguyen/papercolor-theme.git ~/.vim/pack/colors/start/papercolor-theme
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # zsh
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # aria2, rclone 
    # use atm to deploy aria2 ref:https://github.com/P3TERX/aria2.sh
    apt install wget curl ca-certificates
    wget -N git.io/aria2.sh && chmod +x aria2.sh
    mv aria2.sh /usr/bin/atm


    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
}

version_manager() {
    # fnm
    curl -fsSL https://fnm.vercel.app/install | bash
}

get_config() {
    wget -O .vimrc https://cdn.staticaly.com/gh/arbaleast/vps-script/main/.vimrc
    wget -O .zshrc https://cdn.staticaly.com/gh/arbaleast/vps-script/main/.zshrc

    chsh -s /usr/bin/zsh
    source /root/.zshrc
}

install_docker() {
    sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt install docker-ce docker-ce-cli containerd.io

    pip install docker-compose
}

install_warp_manager() {
    wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh 
    chmod +x menu.sh && bash menu.sh
    mv menu.sh /usr/bin/menu
    
    echo "now you can use ${Green_font_prefix}warp${Font_color_suffix} to manage network"
}

# dashboard
#######################################################################

echo && echo -e " vps auto installer ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix} 
 
${Green_font_prefix} 0.${Font_color_suffix} install tools
${Green_font_prefix} 1.${Font_color_suffix} version manager
${Green_font_prefix} 2.${Font_color_suffix} install docker
${Green_font_prefix} 3.${Font_color_suffix} get config
${Green_font_prefix} 4.${Font_color_suffix} install warp_manager
 ———————————————————————" && echo


 ######
 read -e -p " Please input number [0-3]:" num
 case "$num" in
0)
    install_tools
    ;;
1)
    version_manager
    ;;
2)
    install_docker
    ;;
3)
    get_config
    ;;
4)
    install_warp_manager
    ;;
*)
    echo
    echo -e " ${Error} Please input right number"
    ;;
esac