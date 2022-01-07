# sweet-home
Your $HOME in a container 

## Usage

This project allows to use a container as a development environment, running as a unprivileged user.
It also packages the [Nix package manager](https://nixos.org/manual/nix/stable/introduction.html) for
non-root install of packages, and [Home Manager](https://github.com/nix-community/home-manager) for dotfile
management.

On first start, the container will update the local list of channels and run `home-manager switch` to setup the
home configuration (first run will take some time). By default the home configuration only includes tmux, but it can be extended by modifying 
`~/.config/nixpkgs/home.nix` on the device and running `home-manager switch` or setting `NIXPKGS_REPO_URL` env var to
a git repository including a [home.nix](home.nix) and it will clone the configuration into the home config.

Here is [how to get started with home-manager](https://ghedam.at/24353/tutorial-getting-started-with-home-manager-for-nix).

## Running

Build the image

```
docker build -t home-sweet-home .
```

Run the image. This will open a new shell as the `me` user within a container.
```
docker run --rm -ti home-sweet-home
```

It is recommended to set the `/nix` and `/home/me` folders within a volume to avoid
losing package and home folder data.
```
docker run --rm -ti -v packages:/nix -v home:/home/me home-sweet-home
```
