#!/bin/bash
set -euo pipefail

overwrite() {
    if ! colordiff -bu "$2" "$1"; then
        read -rp 'Apply? '
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$1" "$2"
        fi
    fi
}

mkdir -p ~/bin

echo 'Installing base16-shell'
if [ -e ~/.config/base16-shell ]; then
    git -C ~/.config/base16-shell pull
else
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
fi

echo 'Installing vim-plug'
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo 'Applying vimrc'
overwrite vimrc ~/.vimrc

echo 'Installing vim plugins'
vim '+PlugInstall' '+PlugClean' '+PlugUpdate' '+qa'

echo 'Creating tmuxline and promptline'
vim '+TmuxlineSnapshot! ~/.tmuxline.conf' '+PromptlineSnapshot! ~/.promptline.sh' '+qa'

echo 'Applying bashrc'
overwrite bashrc ~/.bashrc

echo 'Applying tmux.conf'
overwrite tmux.conf ~/.tmux.conf

if uname -r | grep -q -- '-microsoft-standard$'; then
    echo 'Applying windows_terminal.json'
    overwrite windows_terminal.json "/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

    echo 'Applying vscode.json'
    overwrite vscode.json "/mnt/c/Users/$USER/AppData/Roaming/Code/User/settings.json"
fi

