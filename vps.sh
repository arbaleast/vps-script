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
# Version: 2.7.4

sh_ver="2.7.4"
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
    apt install -y vim git zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}



# dashboard
#######################################################################

echo && echo -e " vps auto installer ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix} 
 
 ${Green_font_prefix} 0.${Font_color_suffix} install tools
 ———————————————————————" && echo


 ######
 read -e -p " Please input number [0]:" num
 case "$num" in
0)
    install_tools
    ;;
*)
    echo
    echo -e " ${Error} Please input right number"
    ;;
esac