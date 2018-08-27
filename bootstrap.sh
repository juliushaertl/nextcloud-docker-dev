#!/bin/bash

OCC="sudo -u www-data $WEBROOT/occ"

STATUS=`$OCC status`

setup() {
    cp /root/config.php $WEBROOT/config/config.php

    if [ "$SQL" = "mysql" ]
    then
        # wait until mysql is ready
        while ! timeout 1 bash -c "echo > /dev/tcp/nc-database-mysql/3306"; do sleep 2; done
        cp /root/autoconfig_mysql.php $WEBROOT/config/autoconfig.php
        SQLHOST=nc-database-mysql
    fi

    if [ "$SQL" = "pgsql" ]
    then
        while ! timeout 1 bash -c "echo > /dev/tcp/nc-database-postgres/5432"; do sleep 2; done
        cp /root/autoconfig_pgsql.php $WEBROOT/config/autoconfig.php
        SQLHOST=nc-database-postgres
    fi

    if [ "$SQL" = "oci" ]
    then
        cp /root/autoconfig_oci.php $WEBROOT/config/autoconfig.php
    fi

    # We copy the default config to the container
    cp /root/config.php /var/www/html/config/config.php

    chown -R www-data:www-data $WEBROOT/data $WEBROOT/config $WEBROOT/apps-writable

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


}

if [[ "$STATUS" != *"installed: true"* ]]
then
    setup

    # run custom shell script from nc root
    [ -e /var/www/html/nc-dev-autosetup.sh ] && bash /var/www/html/nc-dev-autosetup.sh

    echo "Finished setup using $SQL database…"
fi

echo "=> Watching log file"
tail --follow --retry $WEBROOT/data/nextcloud.log &

echo "=> Starting apache"
exec "$@"
