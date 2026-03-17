# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.


# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi



# ------------------------------------------------------------------------------
# SHELLS and PATHS
# ------------------------------------------------------------------------------

# PATH: ZSHELL - CONFIGS - SCRIPTS
export CONFIG=~/pi-config
export PATH=$PATH:$CONFIG

export SCRIPTS=$CONFIG/scripts
export "PATH=$SCRIPTS:$PATH"


# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
# aliases beware!  The order of them is critical, since aliases build on aliases.
# https://stackoverflow.com/questions/22465332/setting-path-environment-variable-in-osx-permanently
# https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html


export ALIASES=$CONFIG/aliases
export "PATH=$ALIASES:$PATH"

# source aliases
source aliases-base
source aliases-help
source aliases-status

source aliases-sysctl
source aliases-sysctl-all
source aliases-sysctl-origin

source aliases-tools
source aliases-ts
source aliases-podman


# ------------------------------------------------------------------------------
# BASH
# ------------------------------------------------------------------------------
# bash completion
# https://sourabhbajaj.com/mac-setup/BashCompletion/
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
# [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"


# set editor
export EDITOR=micro


# ------------------------------------------------------------------------------
# START SCREEN
# ------------------------------------------------------------------------------
clear
echo 'BASH: ' $BASH_VERSION; 
date
