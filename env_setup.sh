# check if device is in GFW or not
function isInGFW() {
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        return 1
    else
        return 0
    fi
}

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
  if isInGFW; then
    # if contains ubuntu, set apt mirror to aliyun
    if [[ $(getSysDist) == *"Ubuntu"* ]]; then
      sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
      sudo sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
      sudo sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
    fi
    # if contains debian, set apt mirror to aliyun
    if [[ $(getSysDist) == *"Debian"* ]]; then
      sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
      sudo sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
      sudo sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
    fi
  fi
}

function setupApps() {
    # for ubuntu and debian
    sudo apt-get update && \
    sudo apt-get install -y curl wget git zsh
  #  TODO:
  #  redhat/centos: yum install git
  #  archlinux: pacman -S git
  #  mac:   brew install git
}

# 中国大陆访问github速度慢，需要使用github镜像
function setupNode(){
    if command -v nvm & > /dev/null; then
        printf "${GREEN}nvm is already installed${NORMAL}\n"
    else
        printf "${BLUE}install nvm into your environment${NORMAL}\n"
        
        if isInGFW; then
            curl -o install_nvm.sh -L https://github.com/nvm-sh/nvm/raw/v0.39.3/install.sh && \
            sed -i 's/https:\/\/github.com/https:\/\/github.com/g' install_nvm.sh && \
            bash install_nvm.sh && \
            sed -i 's/https:\/\/github.com/https:\/\/github.com/g' ~/.nvm/nvm.sh
        else
            curl -o- https://github.com/nvm-sh/nvm/raw/v0.39.3/install.sh | bash
        fi
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \ # This loads nvm
        echo "source $NVM_DIR/nvm.sh" >> ~/.zshrc && \
        echo "source $NVM_DIR/nvm.sh" >> ~/.bashrc
        nvm install 16.0 && \
        nvm use 16.0 && \
        npm install -g nrm yarn pnpm cnpm
        if isInGFW; then
          nrm use taobao
        fi
    fi
}


function setupPython(){
  # install python
  echo "install python"
}

function setupGit() {
  # set git config
  echo "configuring git"
  echo "please enter your git user name:"
  read git_user_name
  echo "please enter your git user email:"
  read git_user_email
  git config --global user.name $git_user_name
  git config --global user.email $git_user_email
  # generate ssh key
  echo "generating ssh key"
  ssh-keygen
  echo "Your ssh key content: (ssh key path: ~/.ssh/id_rsa.pub)"
  cat ~/.ssh/id_rsa.pub
  echo ""
  echo "please add your ssh key to github"
}

# return all available golang versions
function getAvailableGolangVersion() {
  if isInGFW; then
    curl -s https://golang.google.cn/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64.tar.gz' | sed 's/.linux-amd64.tar.gz//g'
  else
    curl -s https://golang.org/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64.tar.gz' | sed 's/.linux-amd64.tar.gz//g'
  fi
}


function setupGolang(){
  # choose golang version
  local golang_version=$(getAvailableGolangVersion | fzf)
  # download golang
  if isInGFW; then
    curl -O https://golang.google.cn/dl/${golang_version}.linux-amd64.tar.gz
  else
    curl -O https://golang.org/dl/${golang_version}.linux-amd64.tar.gz
  fi
  # extract golang
  tar -C /usr/local -xzf ${golang_version}.linux-amd64.tar.gz && \
  # add golang to PATH
  echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zshrc && \
  echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc && \
  # remove golang tarball
  rm -rf ${golang_version}.linux-amd64.tar.gz
}


function setupJava(){
  # install java
  echo "install java"
}


function setupRust(){
  # install rust
  echo "install rust"
}

function setUpZsh() {
  # install oh-my-zsh
  # if exists oh-my-zsh, skip
  if [ -d ~/.oh-my-zsh ]; then
    printf "${GREEN}oh-my-zsh is already installed${NORMAL}\n"
  else
    if isInGFW; then
      sed -i 's/https:\/\/github.com/https:\/\/github.com/g' ./install_zsh.sh && \
      sed -i 's/https:\/\/raw.githubusercontent.com/https:\/\/raw.github.com/g' ./install_zsh.sh
    fi
    bash ./install_zsh.sh
  fi
}

setupApt && \
setupApps && \
setUpZsh && \
setupNode && \
setupGit