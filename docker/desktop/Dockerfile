FROM debian:bookworm

## REF https://github.com/nextcloud/desktop/wiki/System-requirements-for-compiling-the-desktop-client

RUN apt-get update -y && apt-get install -y cmake g++ openssl libssl-dev 
RUN apt-get install -y libzip-dev qtbase5-private-dev qtdeclarative5-dev qtwebengine5-dev qt5keychain-dev qttools5-dev sqlite3 libsqlite3-dev libqt5svg5-dev zlib1g-dev libqt5websockets5-dev qtquickcontrols2-5-dev shared-mime-info libkf5archive-dev inkscape

#RUN apt-get install -y python-nautilus && \
#  wget -O ~/.local/share/nautilus-python/extensions/syncstate-Nextcloud.py "https://raw.githubusercontent.com/nextcloud/desktop/master/shell_integration/nautilus/syncstate.py"



VOLUME /usr/src/

WORKDIR /usr/src

COPY desktop/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

