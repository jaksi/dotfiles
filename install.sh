#!/bin/bash
set -euo pipefail

error() {
    echo "Error: $1"
    exit 1
}

OS=$(uname -s)

case $OS in
Linux)
    PM='sudo apt-get'
    ;;
Darwin)
    command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    PM='brew'
    ;;
*)
    error "Unsupported OS: $OS"
    ;;
esac

install_package() {
    local package=$1
    echo "Installing $package..."
    $PM install -q "$package"
}

maybe_install_package() {
    local cmd=$1
    local package=$cmd
    [[ $# -gt 1 ]] && package=$2
    command -v "$cmd" >/dev/null || install_package "$package"
}

echo 'Updating'
$PM update -q

maybe_install_package fish
FISH=$(which fish)
if ! grep -Fqx "$FISH" /etc/shells; then
    echo "Adding $FISH to /etc/shells..."
    sudo tee -a /etc/shells <<<"$FISH" >/dev/null
fi

echo 'Setting the default shell to fish'
case $OS in
Linux)
    sudo usermod -s "$FISH" "$USER"
    ;;
Darwin)
    sudo dscl . -create "/Users/$USER" UserShell "$FISH"
    ;;
*)
    error "Unsupported OS: $OS"
    ;;
esac

echo 'Configuring fish'
mkdir -p ~/.config/fish
cp config.fish ~/.config/fish/config.fish
cat "config-$OS.fish" >>~/.config/fish/config.fish
PROMPT_LOGIN='(set_color --bold red) (prompt_hostname) (set_color normal)'
HOSTNAME=$(hostname)
HOSTNAME=${HOSTNAME,,}
if [[ $HOSTNAME == *"macbook"* ]]; then
    PROMPT_LOGIN='💻'
elif [[ $HOSTNAME == vps ]]; then
    PROMPT_LOGIN='☁️'
elif [[ $HOSTNAME == "codespaces-"* ]]; then
    PROMPT_LOGIN='🪐'
fi
sed -i.old "s|_PROMPT_LOGIN_|$PROMPT_LOGIN|g" ~/.config/fish/config.fish
rm ~/.config/fish/config.fish.old