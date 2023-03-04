# setup-scripts


## About 
my personal shell set up script.

### Stack

- Shell: Based on **[oh-my-zsh](https://ohmyz.sh/)** install script and [shell-set-up](https://github.com/Thrimbda/shell-set-up)
- System: git/github ssh-key/apt mirror
  - Support for 
    - Ubuntu
    - Debian
- Git: Config git user.name & user.email and ssh key via prompts
- Node: nvm & node & nrm & yarn & cnpm & pnpm
- Python: (WIP) pyenv & python & pip & poetry & pipenv
- Golang: (WIP) gvm & go
- Rust: wip
- Docker: docker & docker-compose
- Tmux: wip
- ......

And all of this will be optional if you don't need it.

## Usage:

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

# Related 

[Thrimbda/shell-set-up](https://github.com/Thrimbda/shell-set-up)