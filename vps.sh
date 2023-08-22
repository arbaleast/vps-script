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
    elif grep -qi "debian" /etc/issue; then
        release="debian"
    elif grep -qi "ubuntu" /etc/issue; then
        release="ubuntu"
    elif grep -qi "centos|red hat|redhat" /etc/issue; then
        release="centos"
    elif  grep -qi "fedora" /etc/os-release; then
        release="fedora"
    elif  grep -qi "debian" /proc/version; then
        release="debian"
    elif  grep -qi "ubuntu" /proc/version; then
        release="ubuntu"
    elif grep -qi "centos|red hat|redhat" /proc/version; then
        release="centos"
    fi
    ARCH=$(uname -m)
    [ "$(command -v dpkg)" ] && dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
}

install_tools() {
    read -rp "请输入需要额外安装的工具，并回车确认：" TOOL
    
    check_sys
    # 检测是哪种类型的linux发行版；暂时区分ubuntu和fedora
    # if [ "$release" = "ubuntu" ];then
    #     sudo apt update && sudo apt upgrade -y
    #     sudo apt install -y vim git zsh language-pack-zh-hans curl htop "$TOOL"
    # elif [ "$release" = "fedora" ];then
        sudo dnf update && sudo dnf upgrade -y
        sudo dnf install -y vim git zsh curl htop screen "$TOOL"  
    echo "LANG=\"zh_CN.UTF-8\"" >> /etc/profile
    # fi

    read -p "请输入需要配置的环境, 可选: 1: alist, 2: vim, 3: zsh, 4: aria2;rclone: \x0a" RUNTIME

    case $RUNTIME in 
        1)
            curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
            ;;
        2)
            # config vim
            mkdir -p ~/.vim/pack/git-plugins/start

            git clone --depth 1 https://gitclone.com/github.com/dense-analysis/ale.git ~/.vim/pack/git-plugins/start/ale
            git clone https://gitclone.com/github.com/pedrohdz/vim-yaml-folds.git ~/.vim/plugged/vim-yaml-folds
            git clone https://gitclone.com/github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLine
            git clone https://gitclone.com/github.com/NLKNguyen/papercolor-theme.git ~/.vim/pack/colors/start/papercolor-theme

            curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://fastly.jsdelivr.net/gh/junegunn/vim-plug@master/plug.vim
            ;;
        3)
            # 安装 ohmhzsh 
            rm -rf ~/.oh-my-zsh
            sh -c "$(curl -fsSL https://fastly.jsdelivr.net/gh/ohmyzsh/ohmyzsh@master/tools/install.sh)"

            # 安装命令补全插件
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

            # zsh配置文件: 添加代理
            cat >> ~/.zshrc << EOF
            function proxy_on() {
                export http_proxy=http://192.168.98.187:7890
                export https_proxy=\$http_proxy
                echo -e "终端代理已开启。"
            }

            function proxy_off(){
                unset http_proxy https_proxy
                echo -e "终端代理已关闭。"
            }
EOF
            # 让zsh配置生效
            source ~/.zshrc
            ;;
        4)
            # aria2, rclone 
            # use atm to deploy aria2 ref:https://github.com/P3TERX/aria2.sh
            apt install wget curl ca-certificates
            wget -N git.io/aria2.sh && chmod +x aria2.sh
            mv aria2.sh /usr/bin/atm
            ;;
        *)
            install_tools
            ;;

        # bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
    esac

}

version_manager() {
    # fnm
    curl -fsSL https://fnm.vercel.app/install | bash
}

get_config() {
    wget -O ~/.vimrc https://cdn.staticaly.com/gh/arbaleast/vps-script/main/.vimrc
    wget -O ~/.zshrc https://cdn.staticaly.com/gh/arbaleast/vps-script/main/.zshrc

    chsh -s /usr/bin/zsh
    source ~/.zshrc
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
 read -erp " Please input number [0-4]:" num
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
