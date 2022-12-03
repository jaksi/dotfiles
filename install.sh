#!/bin/bash
set -euo pipefail

error() {
    echo "Error: $1"
    exit 1
}

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

case $OS in
linux)
    PM='sudo apt-get'
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
        echo 'Updating'
        $PM update
        UPDATED=1
    fi
    echo "Installing $package"
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
    echo "Adding $FISH to /etc/shells"
    sudo tee -a /etc/shells <<<"$FISH" >/dev/null
fi

if [[ $SHELL != "$FISH" ]]; then
    echo "Changing the default shell to $FISH"
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

echo 'Configuring fish'
FISH_CONFIG_FILE=~/.config/fish/config.fish
mkdir -p "$(dirname $FISH_CONFIG_FILE)"
cp config.fish $FISH_CONFIG_FILE
cat "config-$OS.fish" >>$FISH_CONFIG_FILE
PROMPT_LOGIN='(set_color magenta) (prompt_hostname) (set_color normal)'
HOSTNAME=$(hostname | tr '[:upper:]' '[:lower:]')
case $HOSTNAME in
*macbook*)
    PROMPT_LOGIN='(set_color --bold red) MacBook (set_color normal)'
    ;;
vps)
    PROMPT_LOGIN='(set_color --bold green) VPS (set_color normal)'
    ;;
codespaces-*)
    PROMPT_LOGIN='(set_color --bold blue) Codespaces (set_color normal)'
    ;;
esac
sed -i.old "s|_PROMPT_LOGIN_|$PROMPT_LOGIN|g" $FISH_CONFIG_FILE
rm $FISH_CONFIG_FILE.old
