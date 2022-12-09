#!/bin/bash
# shellcheck disable=SC2181

DOMAIN_SUFFIX=".$(echo "$VIRTUAL_HOST" | cut -d '.' -f2-)"
IS_STANDALONE=$([ -z "$VIRTUAL_HOST" ] && echo "true" )

indent() { sed 's/^/   /'; }

# Prepare waiting page during auto installation
cp /root/installing.html /var/www/html/installing.html

output() {
	echo "$@"
	echo "$@" >> /var/www/html/installing.html
}

OCC() {
	output "occ" "$@"
	# shellcheck disable=SC2068
	sudo -E -u www-data php "$WEBROOT/occ" $@ | indent
}

update_permission() {
	chown -R www-data:www-data "$WEBROOT"/apps-writable
	chown -R www-data:www-data "$WEBROOT"/data
	chown www-data:www-data "$WEBROOT"/config
	chown www-data:www-data "$WEBROOT"/config/config.php 2>/dev/null
}

wait_for_other_containers() {
	output "⌛ Waiting for other containers"
	if [ "$SQL" = "mysql" ]
	then
		output " - MySQL"
		while ! timeout 1 bash -c "(echo > /dev/tcp/database-mysql/3306) 2>/dev/null"; do sleep 2; done
		[ $? -ne 0 ] && echo "⚠ Unable to connect to the MySQL server"
		sleep 2
	fi
	if [ "$SQL" = "pgsql" ]
	then
		while ! timeout 1 bash -c "(echo > /dev/tcp/database-postgres/5432) 2>/dev/null"; do sleep 2; done
		[ $? -ne 0 ] && echo "⚠ Unable to connect to the PostgreSQL server"
		sleep 2
	fi
	[ $? -eq 0 ] && output "✅ Database server ready"
}

configure_gs() {
	OCC config:system:set lookup_server --value=""

	if [[ "$IS_STANDALONE" = "true" ]]; then
		return 0
	fi

	get_protocol
	LOOKUP_SERVER="${PROTOCOL}://lookup${DOMAIN_SUFFIX}/index.php"
	MASTER_SERVER="${PROTOCOL}://portal${DOMAIN_SUFFIX}"

	if [ "$GS_MODE" = "master" ]
	then
		OCC app:enable globalsiteselector
		OCC config:system:set lookup_server --value "$LOOKUP_SERVER"
		OCC config:system:set gs.enabled --type boolean --value true
		OCC config:system:set gss.jwt.key --value 'random-key'
		OCC config:system:set gss.mode --value 'master'
		OCC config:system:set gss.master.admin 0 --value 'admin'
		OCC config:system:set gss.master.csp-allow 0 --value "*${DOMAIN_SUFFIX}"
	fi

	if [ "$GS_MODE" = "slave" ]
	then
		OCC app:enable globalsiteselector
		OCC config:system:set lookup_server --value "$LOOKUP_SERVER"
		OCC config:system:set gs.enabled --type boolean --value true
		OCC config:system:set gs.federation --value 'global'
		OCC config:system:set gss.jwt.key --value 'random-key'
		OCC config:system:set gss.mode --value 'slave'
		OCC config:system:set gss.master.url --value "$MASTER_SERVER"
	fi
}

configure_ldap() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		return 0
	fi

	timeout 5 bash -c 'until echo > /dev/tcp/ldap/389; do sleep 0.5; done' 2>/dev/null
	if [ $? -eq 0 ]; then
		output "LDAP server available"
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

configure_oidc() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		return 0
	fi
	OCC app:enable user_oidc
	get_protocol
	OCC user_oidc:provider Keycloak -c nextcloud -s 09e3c268-d8bc-42f1-b7c6-74d307ef5fde -d "$PROTOCOL://keycloak.local.dev.bitgrid.net/auth/realms/Example/.well-known/openid-configuration"
}

PROTOCOL=""
get_protocol() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		PROTOCOL=http
		return 0
	fi

	if [[ "$PROTOCOL" == "" ]]; then
		output " Detecting SSL..."
		timeout 1 bash -c 'until echo > /dev/tcp/proxy/443; do sleep 0.5; done' 2>/dev/null
		if [ $? -eq 0 ]; then
			output "🔑 SSL proxy available, configuring proxy settings"
			PROTOCOL=https
		else
			output "🗝 No SSL proxy, removing overwriteprotocol"
			PROTOCOL=http
		fi
    fi
}

configure_ssl_proxy() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		return 0
	fi

	get_protocol
	if [[ "$PROTOCOL" == "https" ]]; then
		echo "🔑 SSL proxy available, configuring proxy settings"
		OCC config:system:set overwriteprotocol --value https &
		OCC config:system:set overwrite.cli.url --value "https://$VIRTUAL_HOST" &
	else
		echo "🗝 No SSL proxy, removing overwriteprotocol"
		OCC config:system:delete overwriteprotocol &
		OCC config:system:set overwrite.cli.url --value "http://$VIRTUAL_HOST" &
	fi
	update-ca-certificates
}


configure_add_user() {
	export OC_PASS=$1
	OCC user:add --password-from-env "$1"
}


install() {
	DBNAME=$(echo "$VIRTUAL_HOST" | cut -d '.' -f1)
	echo "database name will be $DBNAME"

	if [ "$SQL" = "mysql" ]
	then
		cp /root/autoconfig_mysql.php "$WEBROOT"/config/autoconfig.php
		sed -i "s/dbname' => 'nextcloud'/dbname' => '$DBNAME'/" "$WEBROOT/config/autoconfig.php"
		SQLHOST=database-mysql
	fi

	if [ "$SQL" = "pgsql" ]
	then
		cp /root/autoconfig_pgsql.php "$WEBROOT"/config/autoconfig.php
		sed -i "s/dbname' => 'nextcloud'/dbname' => '$DBNAME'/" "$WEBROOT/config/autoconfig.php"
		SQLHOST=database-postgres
	fi

	if [ "$SQL" = "oci" ]
	then
		cp /root/autoconfig_oci.php "$WEBROOT"/config/autoconfig.php
	fi

	# We copy the default config to the container
	cp /root/config.php "$WEBROOT"/config/config.php
	chown -R www-data:www-data "$WEBROOT"/config/config.php

	mkdir -p "$WEBROOT/apps-extra"

	update_permission

	USER="admin"
	PASSWORD="admin"

	output "🔧 Starting auto installation"
	if [ "$SQL" = "oci" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name=xe --database-host=$SQLHOST --database-user=system --database-pass=oracle
	elif [ "$SQL" = "pgsql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name="$DBNAME" --database-host=$SQLHOST --database-user=postgres --database-pass=postgres
	elif [ "$SQL" = "mysql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name="$DBNAME" --database-host=$SQLHOST --database-user=root --database-pass=nextcloud
	else
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL"
	fi;

	output "🔧 Server installed"

	output "🔧 Provisioning apps"
	OCC app:disable password_policy

	for app in $NEXTCLOUD_AUTOINSTALL_APPS; do
		OCC app:enable "$app"
	done
	configure_gs
	configure_ldap
	configure_oidc

	output "🔧 Finetuning the configuration"
	if [ "$WITH_REDIS" != "NO" ]; then
		cp /root/redis.config.php "$WEBROOT"/config/
	else
		cp /root/apcu.config.php "$WEBROOT"/config/
	fi

	# Setup domains
	# localhost is at index 0 due to the installation
	INTERNAL_IP_ADDRESS=$(ip a show type veth | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
	NEXTCLOUD_TRUSTED_DOMAINS="${NEXTCLOUD_TRUSTED_DOMAINS:-nextcloud} ${VIRTUAL_HOST} ${INTERNAL_IP_ADDRESS} localhost"
	if [ -n "${NEXTCLOUD_TRUSTED_DOMAINS+x}" ]; then
		echo "🔧 setting trusted domains…"
		NC_TRUSTED_DOMAIN_IDX=1
		for DOMAIN in $NEXTCLOUD_TRUSTED_DOMAINS ; do
			DOMAIN=$(echo "$DOMAIN" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
			OCC config:system:set trusted_domains $NC_TRUSTED_DOMAIN_IDX --value="$DOMAIN"
			NC_TRUSTED_DOMAIN_IDX=$((NC_TRUSTED_DOMAIN_IDX + 1))
		done
	fi
	configure_ssl_proxy

	output "🔧 Preparing cron job"

	# Setup initial configuration
	OCC background:cron

	# Trigger initial cron run
	sudo -E -u www-data php cron.php &

	# run custom shell script from nc root
	# [ -e /var/www/html/nc-dev-autosetup.sh ] && bash /var/www/html/nc-dev-autosetup.sh

	output "🔧 Setting up users and LDAP in the background"
	OCC user:setting admin settings email admin@example.net &
	INSTANCENAME=$(echo "$VIRTUAL_HOST" | cut -d '.' -f1)
	configure_add_user "${INSTANCENAME:-nextcloud}" &
	configure_add_user user1 &
	configure_add_user user2 &
	configure_add_user user3 &
	configure_add_user user4 &
	configure_add_user user5 &
	configure_add_user user6 &
	configure_add_user jane &
	configure_add_user john &
	configure_add_user alice &
	configure_add_user bob &

	output "🚀 Finished setup using $SQL database…"
}

add_hosts() {
	echo "Add the host IP as host.docker.internal to /etc/hosts ..."
	ip -4 route list match 0/0 | awk '{print $3 "   host.docker.internal"}' >> /etc/hosts
}

setup() {
	update_permission
	STATUS=$(OCC status)
	if [[ "$STATUS" = *"installed: true"* ]] || [[ ! -f $WEBROOT/config/config.php ]]
	then
		output "🚀 Nextcloud already installed ... skipping setup"

		# configuration that should be applied on each start
		configure_ssl_proxy
	else
		if [ "$NEXTCLOUD_AUTOINSTALL" != "NO" ]
		then
			add_hosts
			install
		fi
	fi

}
check_source() {
	FILE=/var/www/html/status.php
	if [ -f "$FILE" ]; then
		output "Server source is mounted, continuing"
	else
		output "Server source is not present, fetching ${SERVER_BRANCH:-master}"
		git clone --depth 1 --branch "${SERVER_BRANCH:-master}" https://github.com/nextcloud/server.git /tmp/server
		(cd /tmp/server && git submodule update --init)
		output "Cloning additional apps"
		git clone --depth 1 --branch "${SERVER_BRANCH:-master}" https://github.com/nextcloud/viewer.git /tmp/server/apps/viewer

		# shallow clone of submodules https://stackoverflow.com/questions/2144406/how-to-make-shallow-git-submodules
		git config -f .gitmodules submodule.3rdparty.shallow true
		(cd /tmp/server && git submodule update --init)
		rsync -a /tmp/server/ /var/www/html
	fi
	output "Nextcloud server source is ready"
}

tee /etc/apache2/conf-enabled/install.conf << EOF
<Directory "/var/www/html">
AllowOverride None
RewriteEngine On
RewriteBase /
RewriteCond %{REQUEST_URI} !/installing.html$
RewriteRule .* /installing.html [L]
</Directory>
EOF

pkill -USR1 apache2
(
	check_source
	wait_for_other_containers
	setup
	rm /etc/apache2/conf-enabled/install.conf
	pkill -USR1 apache2
) &

touch /var/log/cron/nextcloud.log "$WEBROOT"/data/nextcloud.log

echo "📰 Watching log file"
tail --follow "$WEBROOT"/data/nextcloud.log /var/log/cron/nextcloud.log &

echo "⌚ Starting cron"
/usr/sbin/cron -f &
echo "🚀 Starting apache"
exec "$@"
