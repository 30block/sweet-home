#!/bin/sh
set -e

# Exec the specified command or fall back on sh
if [ $# -eq 0 ]; then
	cmd="/bin/bash"
else
	cmd="$*"
fi

# Add environment variables from the docker image and
# balena to /etc/env, this will ensure that users accessing
# the shell from running the image directly, using ssh or docker exec
# have the same experience.
exclude="HOME PWD USER HOSTNAME SHLVL SSH_AUTHORIZED_KEYS OLDPWD SHELL"
awk "END { 
			for (name in ENVIRON) {
				if (\"${exclude}\" !~ name) {
					print \"export \"name\"='\"ENVIRON[name]\"'\";
				}
			}
    }" </dev/null | sudo tee /etc/env >/dev/null
echo "export SWEET_HOME_VERSION=$(cat </etc/version)" | sudo tee -a /etc/env >/dev/null

# If the user set authorized keys then launch sshd
SSH_SERVER_PORT=${SSH_SERVER_PORT:-2222}
SSH_SERVER_LOGS=${SSH_SERVER_LOGS:-0}
if [ -n "${SSH_AUTHORIZED_KEYS}" ]; then
	# Setup the server keys
	if [ ! -d "${HOME}/.config/etc/ssh" ]; then
		mkdir -p "${HOME}/.config/etc/ssh"
		ssh-keygen -A -f "${HOME}/.config"
	fi

	if [ ! -d "${HOME}/.ssh" ]; then
		mkdir -p "${HOME}/.ssh"
		chmod 0700 "${HOME}/.ssh"
	fi

	# Write the keys
	echo "${SSH_AUTHORIZED_KEYS}" | tr "," "\n" >"${HOME}/.ssh/authorized_keys"
	chmod 0600 "${HOME}/.ssh/authorized_keys"

	# Start the server. By default it drops any output
	if [ "${SSH_SERVER_LOGS}" != "1" ]; then
		/usr/sbin/sshd -D -e -p "${SSH_SERVER_PORT}" >/dev/null 2>&1 &
	else
		/usr/sbin/sshd -D -e -p "${SSH_SERVER_PORT}" &
	fi
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
