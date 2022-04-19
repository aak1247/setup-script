# for ubuntu
function setupApt() {

}

function setupDep() {
    # for ubuntu
    sudo apt-get update && \
    sudo apt-get install -y curl wget git
}


function setupNode(){
    command -v nvm > /dev/null 2>&1 && {
        printf "${GREEN}nvm is already installed${NORMAL}\n"
    } || {
        printf "${BLUE}install nvm into your environment${NORMAL}\n"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \ # This loads nvm
        echo "source $NVM_DIR/nvm.sh" >> ~/.zshrc && \
        echo "source $NVM_DIR/nvm.sh" >> ~/.bashrc
    }
    nvm install 16.0 && \
    nvm use 16.0 && \
    npm install -g nrm yarn pnpm cnpm && \
    nrm use taobao
}


function setupPython(){

}


function setupGolang(){

}


function setupJava(){

}


function setupRust(){

}

setupDep && \
setupNode