# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

alias fun='eval $(alias | awk "/^alias base16_.+=/ {print \$2}" | cut -d = -f 1 | sort -R | head -1)'
if type exa >/dev/null 2>&1; then
    alias ls=exa
fi
if type bat >/dev/null 2>&1; then
    alias cat='bat --theme base16 -p'
elif type batcat >/dev/null 2>&1; then
    alias cat='batcat --theme base16 -p'
fi
alias diff='colordiff -u'
alias s='sudo -E'
alias l='ls -la'

export PATH="${HOME}/go/bin:${HOME}/bin:${PATH}"

source ~/.promptline.sh

