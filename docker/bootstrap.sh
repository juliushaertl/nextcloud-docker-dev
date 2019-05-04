#!/bin/bash

OCC="sudo -E -u www-data $WEBROOT/occ"

update_permission() {
	chown www-data:www-data $WEBROOT/config
	chown -R www-data:www-data $WEBROOT/config/config.php
	chown -R www-data:www-data $WEBROOT/data
	chown -R www-data:www-data $WEBROOT/apps-writable
}

wait_for_other_containers() {

	if [ "$SQL" = "mysql" ]
	then
		# wait until mysql is ready
		while ! timeout 1 bash -c "echo > /dev/tcp/database-mysql/3306"; do sleep 2; done
		sleep 2
	fi
	if [ "$SQL" = "pgsql" ]
	then
		while ! timeout 1 bash -c "echo > /dev/tcp/database-postgres/5432"; do sleep 2; done
	fi
}
setup() {


	if [ "$SQL" = "mysql" ]
	then
		cp /root/autoconfig_mysql.php $WEBROOT/config/autoconfig.php
		SQLHOST=database-mysql
	fi

	if [ "$SQL" = "pgsql" ]
	then
		cp /root/autoconfig_pgsql.php $WEBROOT/config/autoconfig.php
		SQLHOST=database-postgres
	fi

	if [ "$SQL" = "oci" ]
	then
		cp /root/autoconfig_oci.php $WEBROOT/config/autoconfig.php
	fi

    # We copy the default config to the container
	cp /root/config.php $WEBROOT/config/config.php
	chown -R www-data:www-data $WEBROOT/config/config.php

    update_permission

    USER=admin
    PASSWORD=admin
    if [ "$NEXTCLOUD_AUTOINSTALL" = "YES" ]
    then
	    echo "Starting auto installation"
	    if [ "$SQL" = "oci" ]; then
		    $OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=xe --database-host=$SQLHOST --database-user=system --database-pass=oracle
	    else
		    $OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=nextcloud --database-host=$SQLHOST --database-user=nextcloud --database-pass=nextcloud
	    fi;

	    for app in $NEXTCLOUD_AUTOINSTALL_APPS; do
		    echo "Enable app ${app}"
		    $OCC app:enable $app
	    done
    fi;

	if [ "$WITH_REDIS" = "YES" ]; then
		cp /root/redis.config.php $WEBROOT/config/
	fi
	$OCC user:setting admin settings email admin@example.net


}

add_user() {
	export OC_PASS=$1
	$OCC user:add --password-from-env $1
}

install() {
	STATUS=`$OCC status`
	if [[ "$STATUS" != *"installed: true"* ]]
	then
		setup

		add_user user1
		add_user user2
		add_user user3
		add_user user4
		add_user user5
		add_user user6

	    # run custom shell script from nc root
	    # [ -e /var/www/html/nc-dev-autosetup.sh ] && bash /var/www/html/nc-dev-autosetup.sh

	    echo "Finished setup using $SQL database…"
	else
		echo "Nextcloud already installed ... skipping setup"
	fi
}

wait_for_other_containers
install
update_permission

echo "=> Watching log file"
tail --follow --retry $WEBROOT/data/nextcloud.log &

echo "=> Starting apache"
exec "$@"
