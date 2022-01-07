ARG USER=me
ARG UID=1000

FROM nixos/nix as nix

RUN mkdir -p /output/store && \
    nix-env --profile /output/profile -i home-manager nix && \
    cp -va $(nix-store -qR /output/profile) /output/store


FROM alpine

ARG USER
ARG UID

# Copy nix dependencies
COPY --from=nix --chown=${UID} /output/store /nix/store
COPY --from=nix /output/profile/ /usr/local/

# Install minimal tools and create user
RUN apk --update add --no-cache sudo tini iputils git && \
    adduser -D -s /bin/bash -u $UID $USER && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chmod 0440 /etc/sudoers && \
    chown ${USER} /nix

USER ${UID}

# Set environment variables
ENV USER ${USER}
ENV HOME /home/${USER}
ENV TERM "xterm-color"
ENV NIX_PATH=${HOME}/.nix-defexpr/channels

RUN mkdir -p ${HOME}/.config/nixpkgs && \
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable

# Copy local files
COPY --chown=${UID} home.nix ${HOME}/.config/nixpkgs/
COPY entry.sh /usr/local/bin/

ENTRYPOINT ["tini", "--", "entry.sh"]

WORKDIR $HOME
VOLUME $HOME
