#!/bin/bash
set -euo pipefail

overwrite() {
    if [ -e "$2" ]; then
        if ! colordiff -bu "$2" "$1"; then
            read -rp 'Apply? '
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp "$1" "$2"
            fi
        fi
    fi
}

add_source() {
    touch "$1"
    if ! grep -Fq "$2" "$1"; then
        echo "$2" >> "$1"
    fi
}

mkdir -p ~/bin

echo 'Installing base16-shell'
if [ -e ~/.config/base16-shell ]; then
  git -C ~/.config/base16-shell pull
else
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
fi

echo 'Installing exa'
curl -Lo /tmp/exa.zip "$(curl -s https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[] | select(.name | startswith("exa-linux-x86_64")).browser_download_url')"
unzip /tmp/exa.zip -d /tmp
mv /tmp/exa-linux-x86_64 ~/bin/exa
chmod +x ~/bin/exa

echo 'Installing vim-plug'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo 'Applying vimrc'
add_source ~/.vimrc 'source ~/dotfiles/vimrc'

echo 'Installing vim plugins'
vim '+PlugInstall' '+PlugClean' '+PlugUpdate' '+qa'

echo 'Creating tmuxline and promptline'
vim '+TmuxlineSnapshot! ~/.tmuxline.conf' '+PromptlineSnapshot! ~/.promptline.sh' '+qa'

echo 'Applying bashrc'
add_source ~/.bashrc 'source ~/dotfiles/bashrc'

echo 'Applying tmux.conf'
add_source ~/.tmux.conf 'source-file ~/dotfiles/tmux.conf'

echo 'Applying windows_terminal.json'
overwrite windows_terminal.json "/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

echo 'Applying vscode.json'
overwrite vscode.json "/mnt/c/Users/$USER/AppData/Roaming/Code/User/settings.json"
