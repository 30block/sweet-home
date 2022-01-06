ARG USER=me
ARG UID=1000
FROM alpine AS base

ARG USER
ARG UID

# Install base tools and create user
RUN apk --update add --no-cache sudo xz tini ncurses iputils && \
    adduser -D -s /bin/bash -u $UID $USER && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers && \
    chmod 0440 /etc/sudoers

FROM base AS nix
ARG USER
ARG UID

# Install needs to happen as a non-root user
USER ${UID}
ENV USER ${USER}
ENV HOME /home/${USER}

WORKDIR ${HOME}

COPY --chown=${UID} nix ./nix

# Single user NIX install and home-manager install
RUN sudo apk --update add --no-cache curl xz && \
    curl -L https://nixos.org/nix/install | sh -s -- --no-channel-add && \
    # Prepare local configuration
    mkdir -p ${HOME}/.config/nix && \
    mkdir -p ${HOME}/.config/nixpkgs && \
    echo "experimental-features = nix-command flakes" > ${HOME}/.config/nix/nix.conf && \
    echo ". ${HOME}/.nix-profile/etc/profile.d/nix.sh" > ${HOME}/.profile && \
    # Load nix config so we can build the local system
    . ${HOME}/.nix-profile/etc/profile.d/nix.sh  && \
    nix build "./nix#local.home.activationPackage" && \
    # Activate the the home-manager package
    ./result/activate

FROM base AS runtime

ARG USER
ARG UID
 
# Set environment variables
ENV USER ${USER}
ENV HOME /home/${USER}
ENV TERM "xterm-color"

USER ${UID}

WORKDIR $HOME

# Copy configurations from the nix image
COPY --from=nix /nix /nix
COPY --chown=${UID} --from=nix ${HOME}/.nix-defexpr ./.nix-defexpr
COPY --chown=${UID} --from=nix ${HOME}/.config ./.config
COPY --chown=${UID} --from=nix ${HOME}/.profile ./.profile
#
# Copy entrypoint and base home files
COPY entry.sh /usr/local/bin/
COPY ./nix .config/nixpkgs

# .nix-profile needs to be a link
RUN ln -s /nix/var/nix/profiles/per-user/${USER}/profile ${HOME}/.nix-profile

ENTRYPOINT ["tini", "--", "entry.sh"]

# Sleep by default to keep the container from
# dying when started by the supervisor
CMD ["sleep", "infinity"]

VOLUME $HOME
