# sweet-home
Your $HOME in a container

## Usage

This is a work in progress and is bound to change dramatically. 

Build the image, this will take a long time as it downloads the nixpkgs cache 
and **will only work on aarch64 for now**

```
docker build -t home-sweet-home .
```

By default the home configuration only includes `git` and `tmux`. See [nix/home.nix](nix/home.nix).
To add packages modify the file at `~/.config/nixpkgs/home.nix` or set the `NIXPKGS_REPO_URL` env var to
have the entrypoint pull your own configuration into `~/.config/nixpkgs`. The repo must include a `flake.nix` that
matches [nix/flake.nix](nix/flake.nix).
Here is [how to get started with home-manager](https://ghedam.at/24353/tutorial-getting-started-with-home-manager-for-nix)

Run the image (`sh -l` is required to load `.profile` config). This will open a new shell
as the `me` user within a container.
```
docker run --rm -ti home-sweet-home sh -l
```

To update the home configuration run 

```
home-manager switch --flake ~/.config/nixpkgs
```


## TODO

- [] Reduce output image size, this requires figuring out how to clean the nixpkgs cache 
- [] Make flake.nix architecture independent
- [] Create multi-arch images and push to dockerhub (images cannot be built in balena builder as nix install requires access to `/proc`)
