#!/bin/sh
set -e

# Exec the specified command or fall back on sh
if [ $# -eq 0 ]; then
	cmd="/bin/bash"
else
	cmd="$*"
fi

# Use $@ to manage extra git arguments
set -- --recurse-submodules -j8

# Repo branch
NIXPKGS_REPO_BRANCH=${NIXPKGS_REPO_BRANCH:-""}
if [ -n "${NIXPKGS_REPO_BRANCH}" ]; then
	set -- "$@" -b "${NIXPKGS_REPO_BRANCH}"
fi

# Migrate home-manager config to the recommended home
if [ -d "${HOME}/.config/nixpkgs" ]; then
	mv "${HOME}/.config/nixpkgs" "${HOME}/.config/home-manager"
fi

# If a repository was provided, replace default config with the repo config
if [ -n "${NIXPKGS_REPO_URL}" ] && [ ! -d "${HOME}/.config/home-manager/.git" ]; then
	rm -rf "${HOME}/.config/home-manager"
	git clone "$@" "${NIXPKGS_REPO_URL}" "${HOME}/.config/home-manager"
fi

if [ -d "${HOME}/.config/home-manager/.git" ]; then
	cd "${HOME}/.config/home-manager"
	git pull --rebase || git rebase --abort
	cd
fi

# Update channel definitions and install extra dependencies
nix-channel --update
home-manager switch || echo "Failed to load home manager config. Check your home.nix" >&2

exec ${cmd}
