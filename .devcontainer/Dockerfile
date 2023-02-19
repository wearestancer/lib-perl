# syntax=docker/dockerfile:1

ARG DOCKER_REGISTRY=docker.io/wearestancer
ARG PERL_VERSION=5.34

FROM ${DOCKER_REGISTRY}/perl:${PERL_VERSION} AS main

ARG PAUSE_LOGIN ""
ARG PAUSE_PASSWORD ""

CMD [ "sleep", "infinity" ]

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/log/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt <<EOF
  apt update
  apt upgrade -y
  apt install -y --no-install-recommends gpg sudo vim
  apt autoremove -y

  sed -i 's/%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
EOF

# Create user
RUN useradd --create-home --shell /bin/bash --groups sudo vscode -u 1000
USER vscode

# Pause credentials
RUN <<EOF
  echo "user ${PAUSE_LOGIN}" >> "${HOME}/.pause"
  echo "password ${PAUSE_PASSWORD}" >> "${HOME}/.pause"
EOF
