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
    if ! command -v brew >/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    PM='brew'
    ;;
*)
    error "Unsupported OS: $OS"
    ;;
esac

UPDATED=0
install_packages() {
    local packages=$*
    if [[ $UPDATED -eq 0 ]]; then
        log 'Updating'
        $PM update
        UPDATED=1
    fi
    log "Installing packages: $packages"
    #shellcheck disable=SC2086
    $PM install $packages
}

maybe_install_packages() {
    local cmd=$1
    local packages=$cmd
    [[ $# -gt 1 ]] && packages=${*:2}
    command -v "$cmd" >/dev/null || install_packages "$packages"
}

if [[ $OS == darwin ]]; then
    maybe_install_packages bat
else
    maybe_install_packages batcat bat
fi

maybe_install_packages exa
maybe_install_packages fish
maybe_install_packages gh
maybe_install_packages git
maybe_install_packages htop
maybe_install_packages jq
maybe_install_packages tmux
maybe_install_packages vim
maybe_install_packages yq

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
HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')
HOST=$HOSTNAME
ROLE=server
case $HOSTNAME in
*macbook*)
    HOST='MacBook'
    ROLE=client
    ;;
*desktop-windows)
    HOST='WSL'
    ROLE=client
    ;;
vps)
    HOST='VPS'
    ;;
codespaces-*)
    HOST='Codespaces'
    ;;
esac
FISH_CONFIG_FILE=~/.config/fish/config.fish
mkdir -p "$(dirname $FISH_CONFIG_FILE)"
cat config.fish >$FISH_CONFIG_FILE
[[ -f "config-$OS.fish" ]] && cat "config-$OS.fish" >>$FISH_CONFIG_FILE
[[ -f "config-$ROLE.fish" ]] && cat "config-$ROLE.fish" >>$FISH_CONFIG_FILE
sed -i.old "s|_HOST_|$HOST|g" $FISH_CONFIG_FILE
rm $FISH_CONFIG_FILE.old

log 'Configuring git'
cat gitconfig >~/.gitconfig

log 'Configuring htop'
mkdir -p ~/.config/htop
cat htoprc >~/.config/htop/htoprc

log 'Configuring ssh'
mkdir ~/.ssh 2>/dev/null && chmod 700 ~/.ssh
cat ssh_config >~/.ssh/config

log 'Configuring tmux'
cat tmux.conf >~/.tmux.conf
sed -i.old "s|_HOST_|$HOST|g" ~/.tmux.conf
rm ~/.tmux.conf.old

log 'Configuring vim'
cat vimrc >~/.vimrc
