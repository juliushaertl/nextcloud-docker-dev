# nextcloud-dev-docker-compose

Nextcloud development environment using docker-compose 

## Features

- sqlite setup running on localhost:8010
- mysql setup running on localhost:8011
- Xdebug enabled

## Getting started

(with docker.io as root)

    git clone https://github.com/juliushaertl/nextcloud-docker-dev
    git clone git@github.com:nextcloud/server.git
    export NEXTCLOUD_SOURCE=$PWD/server
    docker-compose up

## Environment variables

	NEXTCLOUD_SOURCE				local path to your nextcloud source directory
	NEXTCLOUD_AUTOINSTALL			set to YES if you want to automatically install 
	NEXTCLOUD_AUTOINSTALL_APPS		set list of apps to be enabled after installation

## Using the nc-dev-setup script

Clone the repos

    git clone https://github.com/juliushaertl/nextcloud-docker-dev.git
    git clone https://github.com/nextcloud/server.git

Create a configuration directory

    mkdir -p ~/.nextcloud/nc-dev-setup/

Symlink docker-compose file and binary
    
    # why this? ln -s nc-dev /usr/local/bin/nc-dev-setup
    ln -s $PWD/nextcloud-docker-dev/docker-compose.yml ~/.nextcloud/nc-dev-setup/docker-compose.yml

Create a configuration file for your source tree:

    echo "NEXTCLOUD_SOURCE=$PWD/server" > ~/.nextcloud/nc-dev-setup/master.conf
    echo "NEXTCLOUD_AUTOINSTALL=YES" >> ~/.nextcloud/nc-dev-setup/master.conf
    echo "NEXTCLOUD_AUTOINSTALL_APPS=YES" >> ~/.nextcloud/nc-dev-setup/master.conf

If you want to use multiple nextcloud versions in parallel, you can easily add another configuration file for that:


    echo "NEXTCLOUD_SOURCE=$PWD/server" > ~/.nextcloud/nc-dev-setup/stable12.conf
    echo "NEXTCLOUD_AUTOINSTALL=YES" >> ~/.nextcloud/nc-dev-setup/stable12.conf
    echo "NEXTCLOUD_AUTOINSTALL_APPS=YES" >> ~/.nextcloud/nc-dev-setup/stable12.conf



## LDAP

Example ldif is generated using http://ldapwiki.com/wiki/LDIF%20Generator
