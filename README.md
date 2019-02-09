# nextcloud-dev-docker-compose

Nextcloud development environment using docker-compose 

## Features

- sqlite setup running on localhost:8010
- mysql setup running on localhost:8011
- Xdebug enabled

## Getting started

    git clone git@github.com:juliushaertl/nextcloud-docker-dev.git
    git clone git@github.com:nextcloud/server.git
    cd server
    mkdir apps-extra
    export NEXTCLOUD_SOURCE=$PWD
    cd -
    docker-compose up

Then Nextcloud is accessible in http://172.18.0.5/

## Environment variables

	NEXTCLOUD_SOURCE				local path to your nextcloud source directory
	NEXTCLOUD_AUTOINSTALL			set to YES if you want to automatically install 
	NEXTCLOUD_AUTOINSTALL_APPS		set list of apps to be enabled after installation

## Using the nc-dev-setup script

Clone the repo to some location of your choice

    git clone https://github.com/juliushaertl/nextcloud-docker-dev.git
    cd nextcloud-docker-dev

Create a configuration directory

    mkdir -p ~/.nextcloud/nc-dev-setup/

Symlink docker-compose file and binary
    
    ln -s nc-dev-setup /usr/local/bin/nc-dev
    ln -s docker-compose.yml ~/.nextcloud/nc-dev-setup/docker-compose.yml

Create a configuration file for your source tree:

    echo "NEXTCLOUD_SOURCE=~/repos/nextcloud/server" > ~/.nextcloud/nc-dev-server/master.conf
    echo "NEXTCLOUD_AUTOINSTALL=YES" >> ~/.nextcloud/nc-dev-server/master.conf
    echo "NEXTCLOUD_AUTOINSTALL_APPS=YES" >> ~/.nextcloud/nc-dev-server/master.conf

If you want to use multiple nextcloud versions in parallel, you can easily add another configuration file for that:


    echo "NEXTCLOUD_SOURCE=~/repos/nextcloud/server" > ~/.nextcloud/nc-dev-server/stable12.conf
    echo "NEXTCLOUD_AUTOINSTALL=YES" >> ~/.nextcloud/nc-dev-server/stable12.conf
    echo "NEXTCLOUD_AUTOINSTALL_APPS=YES" >> ~/.nextcloud/nc-dev-server/stable12.conf



## LDAP

Example ldif is generated using http://ldapwiki.com/wiki/LDIF%20Generator
