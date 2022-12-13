#!/bin/bash
set -euo pipefail

error() {
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

log() {
    echo -e "\033[1;32m$1\033[0m"
}

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

case $OS in
linux)
    PM='sudo apt-get -y'
    ;;
darwin)
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    PM='brew'
    ;;
*)
    error "Unsupported OS: $OS"
    ;;
esac

UPDATED=0
install_package() {
    local package=$1
    if [[ $UPDATED -eq 0 ]]; then
        log 'Updating'
        $PM update
        UPDATED=1
    fi
    log "Installing $package"
    $PM install "$package"
}

maybe_install_package() {
    local cmd=$1
    local package=$cmd
    [[ $# -gt 1 ]] && package=$2
    command -v "$cmd" >/dev/null || install_package "$package"
}

maybe_install_package fish
FISH=$(which fish)
if ! grep -Fqx "$FISH" /etc/shells; then
    log "Adding $FISH to /etc/shells"
    sudo tee -a /etc/shells <<<"$FISH" >/dev/null
fi

if [[ $SHELL != "$FISH" ]]; then
    log "Changing the default shell to $FISH"
    case $OS in
    linux)
        sudo usermod -s "$FISH" "$USER"
        ;;
    darwin)
        sudo dscl . -create "/Users/$USER" UserShell "$FISH"
        ;;
    *)
        error "Unsupported OS: $OS"
        ;;
    esac
fi

log 'Configuring fish'
FISH_CONFIG_FILE=~/.config/fish/config.fish
HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')
HOST=$HOSTNAME
case $HOSTNAME in
*macbook*)
    HOST='MacBook'
    ;;
vps)
    HOST='VPS'
    ;;
codespaces-*)
    HOST='Codespaces'
    ;;
esac
mkdir -p "$(dirname $FISH_CONFIG_FILE)"
cat "config-$OS.fish" config.fish >$FISH_CONFIG_FILE
sed -i.old "s|_HOST_|$HOST|g" $FISH_CONFIG_FILE
rm $FISH_CONFIG_FILE.old

log 'Configuring vim'
cat vimrc >~/.vimrc

log 'Configuring ssh'
mkdir ~/.ssh 2>/dev/null && chmod 700 ~/.ssh
cat ssh_config >~/.ssh/config

maybe_install_package htop
log 'Configuring htop'
mkdir -p ~/.config/htop
cat htoprc >~/.config/htop/htoprc

maybe_install_package tmux
log 'Configuring tmux'
cat tmux.conf >~/.tmux.conf
sed -i.old "s|_HOST_|$HOST|g" ~/.tmux.conf
rm ~/.tmux.conf.old
