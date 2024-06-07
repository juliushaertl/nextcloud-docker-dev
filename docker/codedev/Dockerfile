FROM --platform=linux/amd64 ubuntu:24.04

RUN apt update && \
    apt install -y git build-essential zip ccache junit4 libkrb5-dev nasm graphviz python3 python3-dev qtbase5-dev libkf5coreaddons-dev libkf5i18n-dev libkf5config-dev libkf5windowsystem-dev libkf5kio-dev autoconf libcups2-dev libfontconfig1-dev gperf default-jdk doxygen libxslt1-dev xsltproc libxml2-utils libxrandr-dev libx11-dev bison flex libgtk-3-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev ant ant-optional libnss3-dev libavahi-client-dev libxt-dev \
        sudo git vim wget curl \
        dialog \
        libpoco-dev python3-polib libcap-dev npm \
		libpam-dev wget git build-essential libtool \
		libcap2-bin python3-lxml libpng-dev libcppunit-dev \
		pkg-config fontconfig \
	&& rm -rf /var/lib/apt/lists/*

RUN npm install -g sass

RUN adduser --quiet --disabled-password --gecos '' --system --group --home /collabora cool
RUN adduser cool sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

EXPOSE 9980

USER cool
