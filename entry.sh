#!/bin/sh
set -e

# Exec the specified command or fall back on sh
if [ $# -eq 0 ]; then
	cmd="sh"
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

# If a repository was provided, replace default config with the repo config
if [ -n "${NIXPKGS_REPO_URL}" ] && [ ! -d "${HOME}/.config/nixpkgs/.git" ]; then
	rm -rf "${HOME}/.config/nixpkgs"
	git clone "$@" "${NIXPKGS_REPO_URL}" "${HOME}/.config/nixpkgs"
fi

# Update channel definitions and install extra dependencies
nix-channel --update
home-manager switch

exec ${cmd}
