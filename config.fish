if status is-interactive; and not set -q TMUX
    set -l uptime
    if test (uname -s) = 'Darwin'
        set uptime (math (date +%s)'-'(sysctl -n kern.boottime | cut -d ' ' -f 4 | cut -d , -f 1))
    else
        set uptime (cut -d ' ' -f 1 /proc/uptime)
    end
    if test $uptime -gt 432000; and read --nchars 1 -l response --prompt-str='Up more than 5 days. Reboot? (y) '; and test $response = 'y'
        if test (uname -s) = 'Darwin'
            osascript -e 'tell app "System Events" to restart'
        else
            reboot
        end
    end
end

function prompt_login
    echo -ns (set_color --bold brblue) _HOST_ (set_color normal)
end
