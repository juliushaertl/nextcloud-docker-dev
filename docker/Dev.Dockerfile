ARG PHP_VERSION
FROM ghcr.io/juliushaertl/nextcloud-dev-php${PHP_VERSION}:latest


ARG RUN_USER
ARG RUN_UID
ARG RUN_GROUP
ARG RUN_GID

RUN groupadd -o -g $RUN_GID $RUN_GROUP  && \
   useradd -m -s /bin/bash -o -u $RUN_UID -g $RUN_GID $RUN_USER && \
   groupmod -o -g ${RUN_GID} www-data && \
    usermod -o -u ${RUN_UID} -g www-data www-data

#USER $RUN_USER

