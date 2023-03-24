#syntax=docker/dockerfile:1.2

ARG SILETAG

FROM ghcr.io/sile-typesetter/sile:$SILETAG AS fontproof

# This is a hack to convince Docker Hub that its cache is behind the times.
# This happens when the contents of our dependencies changes but the base
# system hasn’t been refreshed. It’s helpful to have this as a separate layer
# because it saves a lot of time for local builds, but it does periodically
# need a poke. Incrementing this when changing dependencies or just when the
# remote Docker Hub builds die should be enough.
ARG DOCKER_HUB_CACHE=0

ARG RUNTIME_DEPS

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install run-time dependecies
RUN pacman --needed --noconfirm -Sq $RUNTIME_DEPS && yes | pacman -Sccq

# Set at build time, forces Docker’s layer caching to reset at this point
ARG REVISION
ARG VERSION

# Install fontproof in SILE container
COPY ./ /src
WORKDIR /src
RUN luarocks install

LABEL org.opencontainers.image.title="FontProof"
LABEL org.opencontainers.image.description="A containerized version of FontProof"
LABEL org.opencontainers.image.authors="Caleb Maclennan <caleb@alerque.com>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.url="https://github.com/sile-typesetter/fontproof/pkgs/container/fontproof"
LABEL org.opencontainers.image.source="https://github.com/sile-typesetter/fontproof"
LABEL org.opencontainers.image.version="v$VERSION"
LABEL org.opencontainers.image.revision="$REVISION"

RUN fontproof --version

WORKDIR /data
ENTRYPOINT ["fontproof"]
