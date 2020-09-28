#!/bin/bash
indent() { sed 's/^/   /'; }

OCC() {
	sudo -E -u www-data $WEBROOT/occ $@ | indent
}

update_permission() {
	chown www-data:www-data $WEBROOT/config
	chown -R www-data:www-data $WEBROOT/config/config.php
	chown -R www-data:www-data $WEBROOT/data
	chown -R www-data:www-data $WEBROOT/apps-writable
}

wait_for_other_containers() {
	echo "⌛ Waiting for other containers"
	if [ "$SQL" = "mysql" ]
	then
		echo " - MySQL"
		while ! timeout 1 bash -c "(echo > /dev/tcp/database-mysql/3306) 2>/dev/null"; do sleep 2; done
		[ $? -ne 0 ] && echo "⚠ Unable to connect to the MySQL server"
	fi
	if [ "$SQL" = "pgsql" ]
	then
		while ! timeout 1 bash -c "(echo > /dev/tcp/database-postgres/5432) 2>/dev/null"; do sleep 2; done
		[ $? -ne 0 ] && echo "⚠ Unable to connect to the PostgreSQL server"
	fi
	sleep 2
	[ $? -eq 0 ] && echo "✅ Database server ready"
}

configure_ldap() {
	timeout 5 bash -c 'until echo > /dev/tcp/ldap/389; do sleep 0.5; done' 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "LDAP server available"
		export LDAP_USER_FILTER="(|(objectclass=inetOrgPerson))"
	
		OCC app:enable user_ldap
		OCC ldap:create-empty-config
		OCC ldap:set-config s01 ldapAgentName "cn=admin,dc=planetexpress,dc=com"
		OCC ldap:set-config s01 ldapAgentPassword "admin"
		OCC ldap:set-config s01 ldapAttributesForUserSearch "sn;givenname"
		OCC ldap:set-config s01 ldapBase "dc=planetexpress,dc=com"
		OCC ldap:set-config s01 ldapEmailAttribute "mail"
		OCC ldap:set-config s01 ldapExpertUsernameAttr "uid"
		OCC ldap:set-config s01 ldapGroupDisplayName "description"
		OCC ldap:set-config s01 ldapGroupFilter '(|(objectclass=groupOfNames))'
		OCC ldap:set-config s01 ldapGroupFilterObjectclass 'groupOfNames'
		OCC ldap:set-config s01 ldapGroupMemberAssocAttr 'member'
		OCC ldap:set-config s01 ldapHost 'ldap'
		OCC ldap:set-config s01 ldapLoginFilter "(&$LDAP_USER_FILTER(uid=%uid))"
		OCC ldap:set-config s01 ldapLoginFilterMode '1'
		OCC ldap:set-config s01 ldapLoginFilterUsername '1'
		OCC ldap:set-config s01 ldapPort '389'
		OCC ldap:set-config s01 ldapTLS '0'
		OCC ldap:set-config s01 ldapUserDisplayName 'cn'
		OCC ldap:set-config s01 ldapUserFilter "$LDAP_USER_FILTER"
		OCC ldap:set-config s01 ldapUserFilterMode "1"
		OCC ldap:set-config s01 ldapConfigurationActive "1"
	fi
}

configure_ssl_proxy() {
	timeout 5 bash -c 'until echo > /dev/tcp/proxy/443; do sleep 0.5; done'
	if [ $? -eq 0 ]; then
		echo "🔑 SSL proxy available, configuring proxy settings"
		OCC config:system:set overwriteprotocol --value https
		OCC config:system:set overwrite.cli.url --value "https://$VIRTUAL_HOST"
	else
		echo "🗝 No SSL proxy, removing overwriteprotocol"
		OCC config:system:set overwriteprotocol --value ""
		OCC config:system:set overwrite.cli.url --value "http://$VIRTUAL_HOST"
	fi
}


configure_add_user() {
	export OC_PASS=$1
	OCC user:add --password-from-env $1
}


install() {


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

	echo "🔧 Starting auto installation"
	if [ "$SQL" = "oci" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=xe --database-host=$SQLHOST --database-user=system --database-pass=oracle
	elif [ "$SQL" = "pgsql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=nextcloud --database-host=$SQLHOST --database-user=postgres --database-pass=postgres
	elif [ "$SQL" = "mysql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL --database-name=nextcloud --database-host=$SQLHOST --database-user=nextcloud --database-pass=nextcloud
	else
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database=$SQL
	fi;

	OCC app:disable password_policy

	for app in $NEXTCLOUD_AUTOINSTALL_APPS; do
		OCC app:enable $app
	done
	configure_ldap

	if [ "$WITH_REDIS" = "YES" ]; then
		cp /root/redis.config.php $WEBROOT/config/
	fi
	OCC user:setting admin settings email admin@example.net

	# Setup domains
	# localhost is at index 0 due to the installation
	INTERNAL_IP_ADDRESS=`ip a show type veth | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"`
	NEXTCLOUD_TRUSTED_DOMAINS="${NEXTCLOUD_TRUSTED_DOMAINS:-nextcloud} ${VIRTUAL_HOST} ${INTERNAL_IP_ADDRESS} localhost"
	if [ -n "${NEXTCLOUD_TRUSTED_DOMAINS+x}" ]; then
		echo "🔧 setting trusted domains…"
		NC_TRUSTED_DOMAIN_IDX=1
		for DOMAIN in $NEXTCLOUD_TRUSTED_DOMAINS ; do
			DOMAIN=$(echo "$DOMAIN" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
			OCC config:system:set trusted_domains $NC_TRUSTED_DOMAIN_IDX --value=$DOMAIN
			NC_TRUSTED_DOMAIN_IDX=$(($NC_TRUSTED_DOMAIN_IDX+1))
		done
	fi
	configure_ssl_proxy


	# Setup initial configuration
	configure_add_user user1
	configure_add_user user2
	configure_add_user user3
	configure_add_user user4
	configure_add_user user5
	configure_add_user user6
	configure_add_user jane
	configure_add_user john
	configure_add_user alice
	configure_add_user bob

	OCC background:cron

	# run custom shell script from nc root
	# [ -e /var/www/html/nc-dev-autosetup.sh ] && bash /var/www/html/nc-dev-autosetup.sh

	echo "🚀 Finished setup using $SQL database…"

}

add_hosts() {
	echo "Add the host IP as host.docker.internal to /etc/hosts ..."
	ip -4 route list match 0/0 | awk '{print $3 "   host.docker.internal"}' >> /etc/hosts
}

setup() {
	STATUS=`OCC status`
	if [[ "$STATUS" != *"installed: true"* ]]
	then
		if [ "$NEXTCLOUD_AUTOINSTALL" = "YES" ]
		then
			add_hosts
			install
		fi
	else
		echo "🚀 Nextcloud already installed ... skipping setup"

		# configuration that should be applied on each start
		configure_ssl_proxy
	fi

	update_permission
}

wait_for_other_containers
setup

touch /var/log/cron/nextcloud.log $WEBROOT/data/nextcloud.log

echo "📰 Watching log file"
tail --follow $WEBROOT/data/nextcloud.log /var/log/cron/nextcloud.log &

echo "⌚ Starting cron"
/usr/sbin/cron -f &
echo "🚀 Starting apache"
exec "$@"
