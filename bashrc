# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

alias fun='eval $(alias | awk "/^alias base16_.+=/ {print \$2}" | cut -d = -f 1 | sort -R | head -1)'
alias ls=exa
alias cat='batcat -p'

export PATH="${HOME}/go/bin:${HOME}/bin:${PATH}"

source ~/.promptline.sh
