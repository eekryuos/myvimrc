#!/usr/bin/env bash

set -euo pipefail

overwrite=0
sync=0

declare -A plugins
plugins=(
    ['asyncrun.vim']='https://github.com/skywind3000/asyncrun.vim.git'
    ['codeium']='https://github.com/Exafunction/codeium.vim.git'
    ['nerdcommenter']='https://github.com/preservim/nerdcommenter.git'
    ['sideways.vim']='https://github.com/AndrewRadev/sideways.vim'
    ['vim-dirdiff']='https://github.com/will133/vim-dirdiff'
    ['vim-fugitive']='https://github.com/tpope/vim-fugitive.git'
    ['vim-sandwich']='https://github.com/machakann/vim-sandwich.git'
    ['vim-surround']='https://github.com/tpope/vim-surround.git'
#   ['LeaderF']='https://github.com/Yggdroot/LeaderF.git'
)

EXECUTABLE=${0##*/}
EXECUTABLE=${EXECUTABLE%%.*}

PWD=$(pwd)
PWD=$(realpath "$PWD")

abs2home() {
    local absolute_path="$1"
    local home_path="$HOME"

    if [[ "$absolute_path" == $home_path/* ]]; then
        relative_path="~${absolute_path#$home_path}"
        echo "$relative_path"
    else
        echo "$absolute_path is not within the HOME directory."
        exit 2
    fi
}

function config_git()
{
    git config --global alias.dirdiff 'difftool --ignore-submodules --dir-diff --symlinks --tool=vimdirdiff'
    git config --global difftool.vimdirdiff.cmd "vim -f '+next' '+execute \"DirDiff\" argv(0) argv(1)' \$LOCAL \$REMOTE"
}

function spell_check()
{
cat <<"EOF"
#!/bin/bash
ASPELL=$(which aspell)
if [ $? -ne 0 ]; then
    echo "Aspell not installed - unable to check spelling" >&2
    exit
else
    WORDS=$($ASPELL --mode=email --add-email-quote='#' list < "$1" | sort -u)
fi
if [ -n "$WORDS" ]; then
    printf "\e[1;33m  Possible spelling errors found in commit message:\n\e[0m\e[0;31m%s\n\e[0m\e[1;33m  Use git commit --amend to change the message.\e[0m\n\n" "$WORDS" >&2
    exit 1
fi
EOF
}


PWD=$(abs2home $PWD)

function usage()
{
    cat <<-EOF >&2
	    $EXECUTABLE [OPTION]
	    -h | --help print usage
	    -o | --overwrite overwrite exists .vim config directory
	    -s | --sync synchronize the configuration
EOF
}

function create_init()
{
cat <<-EOF
	set rtp+=~/.vim
	so $PWD/init.vim
EOF
}

(($# > 0)) || {
    usage
    exit 0
}

PARSED_OPTIONS=$(getopt -o hos --long help,overwrite,sync -- "$@")
if [ $? -ne 0 ]; then
        echo "Failed to parse options."
            exit 1
fi

eval set -- "$PARSED_OPTIONS"

while true; do
    case "$1" in
        -h | --help)
            usage
            exit 1
            ;;
        -o | --overwrite)
            overwrite=1
            shift
            ;;
        -s | --sync)
            sync=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

(( sync == 0 )) && {
    [[ -e "$HOME/.vim" ]] && {
        echo -e "$EXECUTABLE: $HOME/.vim already exists"
        (( overwrite == 1 )) || exit 0

        [[ -e "$HOME/.vim.bak" ]] && {
            echo -e "$EXECUTABLE: $HOME/.vim.bak already exists, please move it elsewhere."
            exit 1
        }

        mv "$HOME/.vim" "$HOME/.vim.bak"
    }

    [[ -e "$HOME/.vimrc" ]] && {
        echo -e "$EXECUTABLE: $HOME/.vimrc already exists"
        (( overwrite == 1 )) || exit 0

        [[ -e "$HOME/.vimrc.bak" ]] && {
            echo -e "$EXECUTABLE: $HOME/.vimrc.bak already exists, please move it elsewhere."
            exit 1
        }

        mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
    }

    create_init > "$HOME/.vimrc"
}

mkdir -p $HOME/.vim/pack/{github,run,Exafunction}/{start,opt}

[[ -L "$HOME/.vim/colors" ]] || {
    ln -s $(pwd)/colors $HOME/.vim/colors
}

for i in `find $(pwd)/plugin -maxdepth 1 -mindepth 1 -type d`; do
    plugin=$(basename "$i")
    [[ -L "$HOME/.vim/pack/run/start/$plugin" ]] || {
        ln -s "$i" "$HOME/.vim/pack/run/start/"
    }
done

cd $HOME/.vim/pack/run/start && {
    for key in "${!plugins[@]}"; do
        [[ -d "$key" ]] || {
            git clone "${plugins[$key]}" "$key"
        }

        [[ "$key" == "vim-dirdiff" ]] && {
            config_git
        }

    done
}

for i in `find $HOME/.vim/pack -maxdepth 3 -mindepth 3 -type d`; do
    [[ -d "$i/doc" ]] && {
        vim -c ":helptags $i/doc | q"
    }
done

function config_git()
{
    git config --global alias.dirdiff 'difftool --ignore-submodules --dir-diff --symlinks --tool=vimdirdiff'
    git config --global difftool.vimdirdiff.cmd "vim -f '+next' '+execute \"DirDiff\" argv(0) argv(1)' \$LOCAL \$REMOTE"
    git config --global alias.fixup '!git commit --fixup=`git log -1 --pretty=format:%h -- "$1"` "$1"'
}

# vim: set et sw=4 ts=4 sts=4:
