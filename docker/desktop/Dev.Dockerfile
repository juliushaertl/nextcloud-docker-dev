FROM ghcr.io/juliushaertl/nextcloud-dev-desktop:latest

ARG RUN_USER
ARG RUN_UID
ARG RUN_GROUP
ARG RUN_GID

RUN groupadd -o -g $RUN_GID $RUN_GROUP  && \
   useradd -m -s /bin/bash -o -u $RUN_UID -g $RUN_GID $RUN_USER

USER $RUN_USER
