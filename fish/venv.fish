function venv --description 'Creates python virtual environment'
    set -l options (fish_opt --short=h --long=help)
    set options $options (fish_opt --short=v --long=virtual_env --required-val)
    set options $options (fish_opt --short=p --long=python_binary --optional-val)
    set options $options (fish_opt --short=d --long=install-deps --long-only)
    set options $options (fish_opt --short=i --long=install --long-only --optional-val)
    set options $options (fish_opt --short=e --long=edit)
    set options $options (fish_opt --short=n --long=new)
    argparse --name="$_" $options -- $argv
    or return

    if set -q _flag_help
        echo "Usage:"
        echo ------
        echo -e "$_ [options]\n"
        echo "Options: (Do not use space after the flag)"
        echo --------
        echo -e "-v, -virtual_env\tPath to Virtual Environment"
        echo -e "-h, --help\t\tHelp text"
        echo -e "-p, --python_path\tSupply python path"
        echo -e "-e, --edit\t\tedit virtualenv boot script"
        echo -e "-n, --new\t\tOverride existing env"
        echo -e "--install-deps\t\tInstall deps listed in $virtualenv_path/requirements.txt"
        return
    else if set -q _flag_edit
        funced --editor vim --save "$_"
        return
    end

    set virtualenv_path "$_flag_v"
    set install_pkg "$_flag_install"

    if test -z "$virtualenv_path"
        set venv_in_cwd (find . -maxdepth 1 -type d -name '.venv*' -printf "%f\n")
        if test -n "$venv_in_cwd"
            set virtualenv_path (pwd)/"$venv_in_cwd"
        end
    end

    if begin
        test -z "$VIRTUAL_ENV"; and test ! -n "$virtualenv_path"
        end
        echo "[-] Missing virutal Environment path"
        return 1
    end

    if test -n "$VIRTUAL_ENV"
        set virtualenv_path (dirname $VIRTUAL_ENV)
    end

    # Expanding path to realpath
    set virtualenv_path (realpath "$virtualenv_path")

    # Colors
    set start "\x1b[33m"
    set end "\x1b[0m"
    if string match -qr (pwd) "$virtualenv_path"
        set start "\x1b[32m"
    end
    echo -e "$start""[+] Configured Virtual Environment Path: $virtualenv_path$end"

    set venv_path "$virtualenv_path/venv"
    
    set python_path python
    test -n "$_flag_p" && set python_path "$_flag_p"

    if set -q _flag_new
        echo "[+] Configured Python Path: $python_path"

        if test ! -d "$venv_path"
            echo "[+] Creating Virtual Environment Path ($virtualenv_path)"
            mkdir -p "$virtualenv_path"
        end
        if test ! -f $virtualenv_path/more_python_paths.pth
            echo "[+] Creating more_python_paths.pth file in $virtualenv_path"
            touch $virtualenv_path/more_python_paths.pth
        end
        if test ! -f $virtualenv_path/env_vars
            echo "[+] Creating env_vars file in $virtualenv_path"
            touch $virtualenv_path/env_vars
        end
        if test ! -f $virtualenv_path/requirements.txt
            echo "[+] Creating requirements.txt in $virtualenv_path"
            touch $virtualenv_path/requirements.txt
        end

        if test -d "$venv_path"
            set resp (read -l -P "Override $venv_path directory (y/n)? ")
            if test "$resp" = y
                rm -rf $venv_path
            else
                return 1
            end
        end
        # Creating virtual env
        "$python_path" -m venv "$venv_path" --prompt "venv_"("$python_path" --version | rg -o '[\d.]+')
	#virtualenv -p "$python_path" --prompt "venv_"("$python_path" --version | rg -o '[\d.]+') "$venv_path"
    end

    if test ! -d "$venv_path"
        echo -e "\x1b[31m[-] Configured Virtual Environment not found ($venv_path)$end"
        return 1
    end
    # Adding more paths to python path
    # more_python_paths.pth contains the list of abs paths need to be added python path
    # Adding this file into site-packages dir, will add those paths to the python path
    cp "$virtualenv_path/more_python_paths.pth" "$venv_path"/lib/*/site-packages/

    # Activating virtual env
    if test -z "$VIRTUAL_ENV"
        source "$venv_path/bin/activate.fish"
        source "$virtualenv_path/env_vars"
    end

    # After sourcing venv. Can directly use python (instaed of python_path)
    #pip install --upgrade pip

    if begin
            test -n "$_flag_new"; or test -n "$_flag_install_deps"
        end
        python -m pip install -r $virtualenv_path/requirements.txt

    else if test -n "$_flag_install"
        python -m pip install "$_flag_install"
        echo "$_flag_install" >> "$virtualenv_path/requirements.txt"
    end
end
