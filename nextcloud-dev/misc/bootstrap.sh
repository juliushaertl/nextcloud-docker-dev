#!/bin/bash

cp /root/config.php $WEBROOT/config/config.php

OCC="sudo -u www-data $WEBROOT/occ"

if [ "$SQL" = "mysql" ]
then
	# wait until mysql is ready
	while ! timeout 1 bash -c "echo > /dev/tcp/nc-database-mysql/3306"; do sleep 2; done
	cp /root/autoconfig_mysql.php $WEBROOT/config/autoconfig.php
fi

if [ "$SQL" = "pgsql" ]
then
	cp /root/autoconfig_pgsql.php $WEBROOT/config/autoconfig.php
fi

if [ "$SQL" = "oci" ]
then
	cp /root/autoconfig_oci.php $WEBROOT/config/autoconfig.php
fi

chown -R www-data:www-data $WEBROOT/data $WEBROOT/config $WEBROOT/apps-extra

USER=admin
PASSWORD=admin
if [ "$NEXTCLOUD_AUTOINSTALL" = "YES" ]
then
	echo "Starting auto installation"
	if [ "$SQL" = "oci" ]; then
		# oracle is a special snowflake
		$OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=xe --database-host=$SQL --database-user=system --database-pass=oracle
	else
		$OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=nextcloud --database-host=nc-database-mysql --database-user=nextcloud --database-pass=nextcloud
	fi;

	for app in $NEXTCLOUD_AUTOINSTALL_APPS; do
		echo "Enable app ${app}"
		$OCC app:enable $app
	done
fi;


echo "Starting server using $SQL database…"

tail --follow --retry $WEBROOT/data/nextcloud.log &

echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini 
echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini 
echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini 
echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini
echo "xdebug.remote_host=172.17.0.1" >> /usr/local/etc/php/conf.d/xdebug.ini

apache2-foreground
