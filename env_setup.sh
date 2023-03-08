#!/usr/bin/env bash
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
NORMAL="\033[0m"
# github mirror
GITHUB_MIRROR="kgithub.com"
# workspace
WORKSPACE=$(pwd)
# HTTP_PROXY="http://172.168.1.206:7890"
# HTTPS_PROXY="http://172.168.1.206:7890"
# ALL_PROXY="socks5://172.168.1.206:7890"

# python version
PYTHON_VERSION="3.10.4"
PYENV_VERSION=$PYTHON_VERSION
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
# java version (available: 11, 17)
JAVA_VERSION=17
# node version
NODE_VERSION=16.0.0
# go version
GO_VERSION=1.20.1
GO_MIRROR="https://golang.google.cn/dl"
GO_PROXY="https://goproxy.cn,direct"
GO_PRIVATE="gitlab.hive-intel.com"

BASHRC=~/.bashrc

# exit when any command fails
set -e

function handle_error() {
  echo "An error occurred."
  exit 1
}

# trap error
trap 'handle_error' ERR

function checkNeedPrompt() {
  printf "${YELLOW}Do you want to $1? [y/n]${NORMAL}\n"
  read -r -n 1 -s answer
  if [[ $answer != "y" ]]; then
    return 1
  else
    return 0
  fi
}

function checkCmdExist() {
  if [ -f "$1" ]; then
    return 0
  fi
  if command -v "$1" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

function display_error() {
	tput sgr0
	tput setaf 1
	echo "ERROR: $1"
	tput sgr0
	exit 1
}

# check if device is in GFW or not
function isInGFW() {
  if command -v wget &> /dev/null; then
    if wget --timeout=2 -q --spider https://www.google.com/; then
      return 1
    else
      return 0
    fi
  fi
  if ping -q -c 1 -W 1 google.com >/dev/null; then
    return 1
  else
    return 0
  fi
}

function getIsInGFW() {
  if isInGFW; then
    echo true
  else
    echo false
  fi
}
IS_IN_GFW=$(getIsInGFW)

# get github mirror
function getGithubMirror() {
  if [ $IS_IN_GFW = true ]; then
    echo $GITHUB_MIRROR
  else
    echo "github.com"
  fi
}
REAL_GITHUB_MIRROR=$(getGithubMirror)
printf "Will use ${GREEN}$REAL_GITHUB_MIRROR${NORMAL} as github mirror\n"

# get system distribution
function getSysDist() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo $ID
  elif type lsb_release >/dev/null 2>&1; then
    lsb_release -i | cut -d: -f2 | sed s/'^\t'//
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    echo $DISTRIB_ID
  elif [ -f /etc/debian_version ]; then
    echo Debian
  elif [ -f /etc/SuSE-release ]; then
    echo SUSE
  elif [ -f /etc/redhat-release ]; then
    echo RedHat
  else
    echo unknown
  fi
}

function setupApt() {
  # check if sources.list configured
  if ! grep -q "mirrors.aliyun.com" /etc/apt/sources.list; then
    if [ $IS_IN_GFW = true ]; then
      printf "${YELLOW}You are in GFW, will use aliyun mirror${NORMAL}\n"
      # if contains ubuntu, set apt mirror to aliyun
      if [[ $(getSysDist) == *"Ubuntu"* ]] || [[ $(getSysDist) == *"ubuntu"* ]]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
        sudo sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
        sudo sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
      fi
      # if contains debian, set apt mirror to aliyun
      if [[ $(getSysDist) == *"Debian"* ]] || [[ $(getSysDist) == *"debian"* ]]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
        sudo sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
        sudo sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
      fi
      printf "${GREEN}apt mirror successfully configured${NORMAL}\n"
    fi
  fi
}

# install apps
function getApps() {
  # return apps list
  echo "curl wget git zsh tmux proxychains-ng"
}

function setupApps() {
  # install needed apps
  if checkNeedPrompt "install or update apps"; then
    if [[ $(getSysDist) == *"Ubuntu"* ]] || [[ $(getSysDist) == *"ubuntu"* ]] || [[ $(getSysDist) == *"Debian"* ]] || [[ $(getSysDist) == *"debian"* ]]; then
      sudo apt-get update && \
      sudo apt-get install -y $(getApps) build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev software-properties-common
    elif [[ $(getSysDist) == *"CentOS"* ]]; then
      sudo yum install -y $(getApps) gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
    elif [[ $(getSysDist) == *"Arch"* ]]; then
      sudo pacman -S --needed --noconfirm $(getApps)  base-devel openssl zlib xz tk
    elif [[ $(getSysDist) == *"Mac"* ]]; then
      brew install $(getApps) openssl readline sqlite3 xz zlib tcl-tk
    else
      display_error "unsupported system"
    fi
    printf "${GREEN}apps successfully installed${NORMAL}\n"
  fi
}

# configure ssh public key
function setupSSH() {
  if checkNeedPrompt "configure ssh public key"; then
    if [ ! -f ~/.ssh/authorized_keys ]; then
      if [ ! -d ~/.ssh ]; then
        mkdir -p ~/.ssh && \
        chmod 700 ~/.ssh
      fi
      touch ~/.ssh/authorized_keys && \
      chmod 600 ~/.ssh/authorized_keys
      printf "${YELLOW}Enter your public key:${NORMAL}\n"
      read -r PUBLIC_KEY
      echo $PUBLIC_KEY >> ~/.ssh/authorized_keys && \
      printf "${GREEN}ssh public key successfully configured${NORMAL}\n"
    fi
  fi
}

function setupNode(){
  if checkCmdExist $NVM_DIR/nvm.sh; then
    printf "${GREEN}nvm is already installed${NORMAL}\n"
  else
    # install nvm
    printf "${BLUE}installing nvm into your environment${NORMAL}\n"
    if [ $IS_IN_GFW = true ]; then
      curl -o .install_nvm.sh -L https://$GITHUB_MIRROR/nvm-sh/nvm/raw/v0.39.3/install.sh && \
      sed -i "s/https:\/\/github.com/https:\/\/$GITHUB_MIRROR/g" .install_nvm.sh && \
      bash .install_nvm.sh && \
      sed -i "s/https:\/\/github.com/https:\/\/$GITHUB_MIRROR/g" ~/.nvm/nvm.sh
    else
      curl -o- https://github.com/nvm-sh/nvm/raw/v0.39.3/install.sh | bash
    fi
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \ # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \ # This loads nvm bash_completion
    echo 'export NVM_DIR=\"$NVM_DIR\"' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc && \
    echo "source $NVM_DIR/nvm.sh" >> ~/.zshrc && \
    echo "source $NVM_DIR/nvm.sh" >> ~/.bashrc && \
    printf "${GREEN}nvm successfully installed${NORMAL}\n" && \
    source $BASHRC && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    npm install -g nrm yarn pnpm cnpm # install nrm / yarn / pnpm / cnpm
    if isInGFW; then
      nrm use taobao
    fi
    printf "${GREEN}nodev$NODE_VERSION and nrm / yarn / pnpm / cnpm are successfully installed${NORMAL}\n"
  fi
}

function setupPython(){
  if checkCmdExist "$PYENV_ROOT/bin/pyenv"; then
    printf "${GREEN}pyenv is already installed${NORMAL}\n"
  else
    # install pyenv
    printf "${BLUE}installing pyenv${NORMAL}\n"
    set -e
    set -o pipefail
    if [ ! -f .install_python.sh ]; then
      curl -L -o .install_python.sh https://$REAL_GITHUB_MIRROR/pyenv/pyenv-installer/raw/master/bin/pyenv-installer
    fi
    if [ $IS_IN_GFW = true ]; then
      sed -i "s/github.com/$REAL_GITHUB_MIRROR/g" .install_python.sh
    fi
    bash .install_python.sh && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc && \
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc && \
    sudo chmod +x pyinstall && \
    cp pyinstall $PYENV_ROOT/bin/pyinstall && \
    source $BASHRC && \
    printf "${GREEN}pyenv is installed${NORMAL}\n"
  fi
  if pyenv versions | grep -q "$PYTHON_VERSION"; then
    printf "${GREEN}python $PYTHON_VERSION is already installed${NORMAL}\n"
  else
    pyinstall $PYTHON_VERSION
  fi
  # install poetry
  if checkCmdExist poetry; then
    printf "${GREEN}poetry is already installed${NORMAL}\n"
  else
    if checkNeedPrompt "install poetry"; then
      printf "${BLUE}installing poetry${NORMAL}\n"
      curl -sSL https://install.python-poetry.org/ | pyenv exec python - && \
      printf "${GREEN}poetry is installed${NORMAL}\n"
      echo 'export PATH="/home/liuyahui/.local/bin:$PATH"' >> ~/.zshrc
      echo 'export PATH="/home/liuyahui/.local/bin:$PATH"' >> ~/.bashrc
    fi
  fi
  # install pipenv
  if checkCmdExist pipenv; then
    printf "${GREEN}pipenv is already installed${NORMAL}\n"
  else
    if checkNeedPrompt "install pipenv"; then
      printf "${BLUE}installing pipenv${NORMAL}\n"
      pyenv shell $PYTHON_VERSION
      pyenv exec pip install pipenv && \
      printf "${GREEN}pipenv is installed${NORMAL}\n"
    fi
  fi
  # 配置pip镜像
  if [ $IS_IN_GFW = true ]; then
    if checkNeedPrompt "Config pip mirror"; then
      printf "${BLUE}Config pip mirror${NORMAL}\n"
      pyenv shell $PYTHON_VERSION
      pyenv exec pip config set global.index-url $PIP_MIRROR
      printf "${GREEN}Pip mirror successfully configured${NORMAL}\n"
    fi
  fi
}

# Configure git
function setupGit() {
  local configured=false
  # check if git user name and email is configured
  if [ -z "$(git config --global user.name)" ]; then
    printf "${BLUE}configuring git${NORMAL}\n"
    # set git config
    printf "${YELLOW}please enter your git user name:${NORMAL}\n"
    read git_user_name
    printf "${YELLOW}please enter your git user email:${NORMAL}\n"
    read git_user_email
    git config --global user.name $git_user_name
    git config --global user.email $git_user_email
    printf "${GREEN}git is configured, name: $git_user_name, email: $git_user_email${NORMAL}\n"
    # generate ssh key
    printf "${BLUE}generating ssh key${NORMAL}\n"
    ssh-keygen
    printf "${BLUE}Your ssh key content: (ssh key path: ~/.ssh/id_rsa.pub)$NORMAL\n"
    cat ~/.ssh/id_rsa.pub
    echo ""
    printf "${YELLOW}please add your ssh key to github${NORMAL}\n"
    configured=false
  else
    printf "${YELLOW}git is configured${NORMAL}\n"
  fi
  if checkNeedPrompt "configure git private token"; then
    printf "${BLUE}configuring private token${NORMAL}\n"
    printf "${YELLOW}please enter your git private token:${NORMAL}\n"
    read git_private_token
    git config --global http.extraheader "PRIVATE-TOKEN: $git_private_token"
    username=$(git config --global user.name)
    printf "${YELLOW}please enter your git private url:${NORMAL}\n"
    read git_private
    printf "${YELLOW}please enter your git private ssh port: (default 22) ${NORMAL}\n"
    read git_private_port
    if [ -z "$git_private_port" ]; then
      git_private_port=22
    fi
    printf "${YELLOW}please enter your git private https port: (default 443) ${NORMAL}\n"
    read git_private_https_port
    if [ -z "$git_private_https_port" ]; then
      git_private_https_port=443
    fi
    git config --global url.ssh://git@$git_private:$git_private_port/%s.git.insteadOf https://$git_private/%s.git
    git config --global url.https://$username:$git_private_token@$git_private:$git_private_https_port/%s.insteadOf https://$git_private/%s
    printf "${GREEN}private git is configured${NORMAL}\n"
    configured=true
  fi
  if $configured; then
    printf "${BLUE}Your git config:${NORMAL}\n"
    git config --global --list
  fi
}

function setupGolang(){
  # install golang
  if checkCmdExist $HOME/.gvm/scripts/env/gvm; then
    printf "${GREEN}gvm is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing gvm${NORMAL}\n"
    if [ ! -f .install_golang.sh ]; then
      curl -o .install_golang.sh -L https://$REAL_GITHUB_MIRROR/moovweb/gvm/raw/master/binscripts/gvm-installer
    fi
    bash .install_golang.sh
    echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> ~/.zshrc
    if isInGFW ; then
      # gvm listall set mirror
      sed -i "s/github.com/$GITHUB_MIRROR/g" ~/.gvm/scripts/listall
      sed -i '2a checkGFW' ~/.gvm/scripts/listall
      # set mirror for gvm install (source)
      sed -i "s/github.com/$GITHUB_MIRROR/g" ~/.gvm/scripts/install
      sed -i '2a checkGFW' ~/.gvm/scripts/install
      # set mirror for gvm install (binary)
      echo 'export GO_BINARY_BASE_URL="$GO_MIRROR"' >> ~/.zshrc
      echo 'export GO_BINARY_BASE_URL="$GO_MIRROR"' >> ~/.bashrc
    fi
    printf "${GREEN}gvm is successfully installed${NORMAL}\n"
  fi
  if checkCmdExist go; then
    printf "${GREEN}golang is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing golang${NORMAL}\n"
    [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
    gvm install go$GO_VERSION -B && \
    gvm use $GO_VERSION --default && \
    go env -w GO111MODULE=on && \
    go env -w GOPROXY=$GO_PROXY && \
    go env -w GOPRIVATE=$GO_PRIVATE && \
    printf "${GREEN}golang is successfully installed${NORMAL}\n" || \
    printf "${RED}golang is not installed${NORMAL}\n"
    # TODO: goprivate Config
  fi
}


function setupJava(){
  # install java
  if checkCmdExist java; then
    printf "${GREEN}java is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing java${NORMAL}\n"
    # Add the Oracle Java PPA to the system
    sudo add-apt-repository ppa:linuxuprising/java -y

    # Update the package index （this will surpass public key check）
    sudo apt-get update | grep NO_PUBKEY | awk '{print $5}' | xargs sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys
    sudo apt-get update

    # Set the debconf selections to automatically accept the Oracle license
    sudo echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections

    # Install Oracle Java
    sudo apt-get install -y oracle-java${JAVA_VERSION}-installer

    printf "${GREEN}java is successfully installed${NORMAL}\n"
  fi
  # TODO: maven / maven mirror / gradle / gradle mirror
}


function setupRust(){
  # install rust
  if checkCmdExist rustc; then
    printf "${GREEN}rust is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing rust${NORMAL}\n"
    curl https://sh.rustup.rs -sSf | sh && \
    echo '. "$HOME/.cargo/env"' >> ~/.zshrc && \
    echo '. "$HOME/.cargo/env"' >> ~/.bashrc && \
    touch $HOME/.cargo/.config
    echo '[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = "ustc"
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"' >> $HOME/.cargo/.config
    printf "${GREEN}rust is successfully installed${NORMAL}\n"
  fi
}

function setUpZsh() {
  # install oh-my-zsh
  # if exists oh-my-zsh, skip
  if [ -d ~/.oh-my-zsh ]; then
    printf "${GREEN}oh-my-zsh is already installed${NORMAL}\n"
    return 0
  fi
  if [ $IS_IN_GFW = true ]; then
    sed -i "s/https:\/\/github.com/https:\/\/$GITHUB_MIRROR/g" ./install_zsh.sh && \
    sed -i "s/https:\/\/raw.githubusercontent.com/https:\/\/raw.$GITHUB_MIRROR/g" ./install_zsh.sh
  fi
  bash ./install_zsh.sh
}

function setUpDocker() {
  # check docker is installed
  if command -v docker &> /dev/null; then
    printf "${GREEN}docker is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing docker into your environment${NORMAL}\n"
    if [ $IS_IN_GFW = true ]; then
      curl -fsSL https://get.daocloud.io/docker | bash
    else
      curl -sSL https://get.daocloud.io/docker | bash
    fi
    sudo chmod 666 /var/run/docker.sock
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    printf "${GREEN}docker is installed${NORMAL}\n"
  fi
  # check docker-compose is installed
  if command -v docker-compose &> /dev/null; then
    printf "${GREEN}docker-compose is already installed${NORMAL}\n"
  else
    printf "${BLUE}installing docker-compose into your environment${NORMAL}\n"
    if [ $IS_IN_GFW = true ]; then
      sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
      sudo chmod +x /usr/local/bin/docker-compose
    else
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
      sudo chmod +x /usr/local/bin/docker-compose
    fi
    printf "${GREEN}docker-compose is installed${NORMAL}\n"
  fi
}

# set up tmux
function setUpTmux() {
  cd ~
  if [ -d .tmux ]; then
    printf "${YELLOW}tmux is already configured${NORMAL}\n"
    cd $WORKSPACE
    return 0
  fi
  printf "${BLUE}configuring tmux${NORMAL}\n" && \
  git clone https://$REAL_GITHUB_MIRROR/aak1247/.tmux.git && \
  ln -s -f .tmux/.tmux.conf && \
  cp .tmux/.tmux.conf.local . && \
  printf "${GREEN}tmux is configured${NORMAL}\n" && \
  cd $WORKSPACE
}

function setupNix() {
  if checkCmdExist nix; then
    printf "${GREEN}nix is already installed${NORMAL}\n"
    return 0
  else
    printf "${BLUE}installing nix${NORMAL}\n"
    sh <(curl -L https://nixos.org/nix/install) --daemon && \
    if [ $? -eq 0 ]; then
      printf "${GREEN}nix is successfully installed${NORMAL}\n"
    else
      printf "${RED}nix is not installed${NORMAL}\n"
    fi
  fi
}

source $BASHRC && \
setupApt && \
setupApps && \
setupSSH && \
setUpZsh && \
setupNode && \
setupGit && \
setUpDocker && \
setUpTmux && \
setupPython && \
setupGolang && \
setupJava && \
setupRust && \
setupNix && \
printf "${GREEN}Congratulations, your env is ready${NORMAL}\n"