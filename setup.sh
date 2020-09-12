#!/bin/bash
set -euo pipefail

mkdir -p ~/bin

if [ ! -e ~/.config/base16-shell ]; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
else
  git -C ~/.config/base16-shell pull
fi

curl -Lo /tmp/exa.zip "$(curl -s https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[] | select(.name | startswith("exa-linux-x86_64")).browser_download_url')"
unzip /tmp/exa.zip -d /tmp
mv /tmp/exa-linux-x86_64 ~/bin/exa
chmod +x ~/bin/exa

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

touch ~/.bashrc
BASHRC_LINE='source ~/dotfiles/bashrc'
if ! grep -Fq "${BASHRC_LINE}" ~/.bashrc; then
  echo "${BASHRC_LINE}" >> ~/.bashrc
fi

touch ~/.vimrc
VIMRC_LINE='source ~/dotfiles/vimrc'
if ! grep -Fq "${VIMRC_LINE}" ~/.vimrc; then
  echo "${VIMRC_LINE}" >> ~/.vimrc
fi
vim '+PlugInstall' '+PlugClean' '+PlugUpdate' +qa
vim '+TmuxlineSnapshot! ~/.tmuxline.conf' '+PromptlineSnapshot! ~/.promptline.sh' '+qa'

touch ~/.tmux.conf
TMUXCONF_LINE='source-file ~/dotfiles/tmux.conf'
if ! grep -Fq "${TMUXCONF_LINE}" ~/.tmux.conf; then
  echo "${TMUXCONF_LINE}" >> ~/.tmux.conf
fi

if [ -e "/mnt/c/Users/${USER}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" ]; then
  cp windows_terminal.json "/mnt/c/Users/${USER}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
fi
