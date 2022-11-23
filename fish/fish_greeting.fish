function fish_greeting
    echo (set_color yellow; date +%T; set_color normal) $hostname
    figlet (id -un)
end
