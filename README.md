# sweet-home

This project provides an quick way to set up a container to serve as a temporary (or permanent) work environment, 
for those instances where you may find yourself working in a different computer and want your favorite tools at your disposal.

## Features

- Work in a container as an unprivileged user.
- Setup your preferred tools through [Nix package manager](https://nixos.org/manual/nix/stable/introduction.html).
  The [nixpkgs-unstable channel](https://nixos.wiki/wiki/Nix_channels) is used by default for access to the latest software versions.
- Configuration (dotfile) management using [Home Manager](https://github.com/nix-community/home-manager).
- Small image size (<60MB compressed).

## Usage

### Quickstart

You can launch a container using one of the pre-built images in [hub.docker.com](https://hub.docker.com/u/pipex/sweet-home) 
(only amd64 and aarch64 architectures are supported).

```sh
docker run --rm --name sweet-home -ti -v packages:/nix -v home:/home/me pipex/sweet-home
```

On start, the container will update the local list of packages from the nix channel and run `home-manager switch` to setup the home configuration,
so on the first run it will take some time to get a shell prompt. 

By design, the base system only includes a minimal set of packages, but the
configuration can be easily extended making changes to `~/.config/nixpkgs/home.nix` and running `home-manager switch`. The changes wil be persisted
on the following run because of the flags `-v packages:/nix -v home:/home/me` that set up these directories as volumes.

A custom startup configuration can be provided to the container through the environment variable `NIXPKGS_REPO_URL`. The variable must point to a public git repository
containing a valid home manager configuration, as it will used to replace the contents of the `~/.config/nixpkgs` directory. For an example, see [my personal configuration](https://github.com/pipex/nixpkgs).

```
docker run --rm --name sweet-home -ti -e NIXPKGS_REPO_URL=https://github.com/pipex/nixpkgs.git -v packages:/nix -v home:/home/me pipex/sweet-home
```

Here is some extra info on how to [get started with home-manager](https://ghedam.at/24353/tutorial-getting-started-with-home-manager-for-nix).


### Docker compose file

To use this image as part of a larger application, or to deploy to your own [balenaCloud](https://www.balena.io/cloud/) fleet, create a 
service in your `docker-compose.yml` as shown below. 

```yaml
version: '2.1'
services:
  sweet-home:
    image: pipex/sweet-home:latest
    privileged: true # (optional) use this is you want to have your container have access to the host
    network_mode: host # (optional) use this to add access to the host network interfaces
    command: sleep infinity # allows the container to run as a daemon
    restart: always
    environment:
      # This is to prevent the Balena supervisor from overriding this value to
      # ensure the right one is used. Do not change this as
      # it has no effect on the runtime username
      USER: 'me'
      # Setting the TZ env var allows for the local date
      # to be shown in tmux and as result of the `date` command
      TZ: 'America/Los_Angeles'
    ports: 
      # If using ssh server (w/o host networking). 
      # Expose container host port 22 to container port 2222
      - "22:2222"
    volumes:
      - home:/home/me # Keep home files accross container restarts
      - pkgs:/nix # Keep package configuration accross container restarts

volumes:
  home:
  pkgs:
```

### Environment variables 

| Name                | Description                                                                                                                                                       | Default Value |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| NIXPKGS_REPO_URL    | Git repository url pointing to a valid home manager configuration. The contents of the `~/.config/nixpkgs` directory will be replaced by the contents of the repo |               |
| NIXPKGS_REPO_BRANCH | Repository branch for the home manager configuration.                                                                                                             |               |
| SWEET_HOME_SHELL    | Set the preferred shell. This configuration will be used when doing `docker run` and on the balena terminal                                                       | sh            |
| SSH_AUTHORIZED_KEYS | Comma delimited list of authorized public keys. If set, the container will launch an SSH server on port 2222                                                      |               |

## Attributions

- [Real estate icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/real-estate)
