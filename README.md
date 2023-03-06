# setup-scripts

English | [简体中文](./README.zh-CN.md)

## About 
my personal Posix env set up script.

### Features

- Shell: Based on **[oh-my-zsh](https://ohmyz.sh/)** install script and [shell-set-up](https://github.com/Thrimbda/shell-set-up)
- System: git/apt mirror/some tools
  - Support for 
    - Ubuntu
    - Debian
- Git: Config git user.name & user.email and ssh key via prompts
- Node: nvm & node & nrm & yarn & cnpm & pnpm
- Python: pyenv & python & pip & poetry & pipenv
- Golang: gvm & go (and config proxy & mirror automatically)
- Rust: wip
- Java: wip
- Docker: docker & docker-compose
- Tmux: tmux and config, based on [aak1247/.tmux](https://github.com/aak1247/.tmux)
- ProxyChains: (WIP) ProxyChains and config
- ......

And all of this will be optional if you don't need it.

### Usage:

```bash
# via curl
sh -c "$(curl -fsSL https://github.com/aak1247/setup_scripts/raw/master/install.sh)"

# via wget
sh -c "$(wget https://github.com/aak1247/setup_scripts/raw/master/install.sh -O -)"
```

## Screenshot
### Zsh
And finally you will get this a beautify zsh! Don't worry your old `.zshrc` would have a backup as `.zshrc.back`.(if you have one.)

![screen-shot](./screenshot/zsh.png)

if you want to adopt my configuration, you can replace `DEFAULT_USER` variable with your username in `.zshrc` and uncomment it if you want (default is `$USER@$HOSTNAME`).

finally, **Do remember install an powerline+awesome([nerd](https://github.com/ryanoasis/nerd-fonts)) font** (here is [meslo](https://github.com/aak1247/setup-scripts/raw/master/font/Meslo%20LG%20M%20Regular%20Nerd%20Font%20Complete.otf) which I am using) to show all these wonderful stuff!

## Related 

- [Thrimbda/shell-set-up](https://github.com/Thrimbda/shell-set-up)
- [.tmux](https://github.com/aak1247/.tmux)