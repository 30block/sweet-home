#!/bin/bash
set -e

# Exec the specified command or fall back on sh
if [ $# -eq 0 ]; then
    cmd=( "bash" )
else
    cmd=( "$@" )
fi

# Always perform initial setup unless told otherwise
if [ -n "${WITH_NIXPKGS}" ]; then
    echo "Running setup. This might take some time ..."

    # Check the nix installation
    if [ ! -d /nix ] || [ ! -f ${HOME}/.nix-profile/etc/profile.d/nix.sh ]; then
        echo "Installing nix"
        sh <(curl -sL https://nixos.org/nix/install)
        echo ". ${HOME}/.nix-profile/etc/profile.d/nix.sh" > ${HOME}/.profile
        echo "export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels" >> ${HOME}/.profile 

        # Load nix config for the rest of the setup, this should not 
        # be necessary on next call
        source ${HOME}/.profile
    fi
        
    # # Setup home-manager
    if [ ! -d ${HOME}/.config/nixpkgs ]; then
        echo "Installing home manager"
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install

        # If a repository was provided, replace default config with the repo config
        if [ -n "${NIXPKGS_REPO_URL}" ]; then
            rm -rf ${HOME}/.config/nixpkgs
            git clone ${NIXPKGS_REPO_URL} ${HOME}/.config/nixpkgs
        fi
    fi   
fi

exec "${cmd[@]}"
