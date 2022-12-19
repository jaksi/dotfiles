if status is-interactive and not set -q TMUX
    exec tmux new-session -As main
end
