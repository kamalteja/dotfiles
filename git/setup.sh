#!/usr/bin/env bash

# Stops execution at a command failure
set -e

read -p "Git username: " name
read -p "Git Email: " email

# User config
git config --global user.name $name
git config --global user.email $email
echo "[+] Configured git username ($name) and email ($email)"

# Core config
gitignore=~/.gitignore
git config --global core.excludesfile $gitignore
! [[ -f $gitignore ]] && touch $gitignore
echo "[+] Configured global git ignore file: $gitignore"

# alias config
# lg
git config --global alias.lg '!f() { args=$@; [ -z "$args" ] && args='\''--all'\''; git log --graph --abbrev-commit --decorate --format=format:'\''%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n%C(white)%s%C(reset) %C(dim white)- %an%C(reset)'\'' $args; }; f'
echo "[+] Configured git aliases"
git config --global --name-only --get-regexp "alias."