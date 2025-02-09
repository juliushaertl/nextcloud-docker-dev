#!/bin/bash
# shellcheck disable=SC2181

# set -o xtrace

DOMAIN_SUFFIX=".$(echo "$VIRTUAL_HOST" | cut -d '.' -f2-)"
IS_STANDALONE=$([ -z "$VIRTUAL_HOST" ] && echo "true" )

indent() { sed 's/^/   /'; }

# Prepare waiting page during auto installation
cp /root/installing.html /var/www/html/installing.html

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

output() {
	echo "$@"
	echo "$@" >> /var/www/html/installing.html
}

fatal() {
	output "======================================================================================="
	output "$@"
	output "======================================================================================="
	exit 1
}

OCC() {
	output "occ" "$@"
	# shellcheck disable=SC2068
	sudo -E -u www-data php "$WEBROOT/occ" $@ | indent
}

is_installed() {
	STATUS=$(OCC status)
	[[ "$STATUS" = *"installed: true"* ]] 
}

update_permission() {
	chown -R www-data:www-data "$WEBROOT"/apps-writable
	chown -R www-data:www-data "$WEBROOT"/data
	chown www-data:www-data "$WEBROOT"/config
	chown www-data:www-data "$WEBROOT"/config/config.php 2>/dev/null

	if [ -f /shared/config.php ]
	then
		ln -sf /shared/config.php "$WEBROOT"/config/user.config.php
	fi
}

configure_xdebug_mode() {
	if [ -n "$PHP_XDEBUG_MODE" ]
	then
		sed -i "s/^xdebug.mode\s*=.*/xdebug.mode = ${PHP_XDEBUG_MODE//\//_}/" /usr/local/etc/php/conf.d/xdebug.ini
		unset PHP_XDEBUG_MODE
	else
		echo "⚠ No value for PHP_XDEBUG_MODE was found. Not updating the setting."
	fi
}

wait_for_other_containers() {
	output "⌛ Waiting for other containers"
	retry_with_timeout() {
		local cmd=$1
		local timeout=$2
		local error_message=$3
		local START_TIME=$SECONDS

		while ! bash -c "$cmd"; do
			if [ "$((SECONDS - START_TIME))" -ge "$timeout" ]; then
				fatal "$error_message"
			fi
			sleep 2
		done
	}

	case "$SQL" in
		"mysql" | "mariadb-replica")
			output " - MySQL"
			retry_with_timeout "(echo > /dev/tcp/database-$SQL/3306) 2>/dev/null" 30 "⚠ Unable to connect to the MySQL server"
			sleep 2
			;;
		"pgsql")
			retry_with_timeout "(echo > /dev/tcp/database-pgsql/5432) 2>/dev/null" 30 "⚠ Unable to connect to the PostgreSQL server"
			sleep 2
			;;
		"maxscale")
			for node in database-mariadb-primary database-mariadb-replica; do
				echo " - Waiting for $node"
				retry_with_timeout "(echo > /dev/tcp/$node/3306) 2>/dev/null" 30 "⚠ Unable to reach to the $node"
				retry_with_timeout "mysql -u root -pnextcloud -h $node -e 'SELECT 1' 2>/dev/null" 30 "⚠ Unable to connect to the $node"
				echo "✅"
			done
			;;
		"oci")
			output " - Oracle"
			retry_with_timeout "(echo > /dev/tcp/database-$SQL/1521) 2>/dev/null" 30 "⚠ Unable to connect to the Oracle server"
			sleep 45
			;;
		"sqlite")
			output " - SQLite"
			;;
		*)
			fatal 'Not implemented'
			;;
	esac
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
	OCC user_oidc:provider Keycloak -c nextcloud -s 09e3c268-d8bc-42f1-b7c6-74d307ef5fde -d "$PROTOCOL://keycloak${DOMAIN_SUFFIX}/realms/Example/.well-known/openid-configuration"
}

PROTOCOL="${PROTOCOL:-http}"
get_protocol() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		PROTOCOL=http
		return 0
	fi
}

configure_ssl_proxy() {
	if [[ "$IS_STANDALONE" = "true" ]]; then
		return 0
	fi

	get_protocol
	if [[ "$PROTOCOL" == "https" ]]; then
		echo "🔑 SSL proxy available, configuring overwrite.cli.url accordingly"
		OCC config:system:set overwrite.cli.url --value "https://$VIRTUAL_HOST" &
	else
		echo "🗝 No SSL proxy, configuring overwrite.cli.url accordingly"
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
	SQLHOST="database-$SQL"
	echo "database name will be $DBNAME"

	USER="admin"
	PASSWORD="admin"

	run_hook_before_install

	output "🔧 Starting auto installation"
	if [ "$SQL" = "oci" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name=FREE --database-host="$SQLHOST" --database-port=1521 --database-user=system --database-pass=oracle
	elif [ "$SQL" = "pgsql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name="$DBNAME" --database-host="$SQLHOST" --database-user=postgres --database-pass=postgres
	elif [ "$SQL" = "mysql" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL" --database-name="$DBNAME" --database-host="$SQLHOST" --database-user=root --database-pass=nextcloud
	elif [ "$SQL" = "mariadb-replica" ]; then
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="mysql" --database-name="$DBNAME" --database-host="database-mariadb-primary" --database-user=root --database-pass=nextcloud
	elif [ "$SQL" = "maxscale" ]; then
		sleep 10
		# FIXME only works for main container as maxscale does not pass root along
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="mysql" --database-name="$DBNAME" --database-host="database-mariadb-primary" --database-user=nextcloud --database-pass=nextcloud
		OCC config:system:set dbhost --value="database-maxscale"
		OCC config:system:set dbuser --value="nextcloud"
	else
		OCC maintenance:install --admin-user=$USER --admin-pass=$PASSWORD --database="$SQL"
	fi;

	if is_installed
	then
		output "🔧 Server installed"
	else
		output "Last nextcloud.log entry:"
		output "$(tail -n 1 "$WEBROOT"/data/nextcloud.log | jq)"
		fatal "🚨 Server installation failed."
	fi

	output "🔧 Provisioning apps"
	OCC app:disable password_policy

	for app in $NEXTCLOUD_AUTOINSTALL_APPS; do
		APP_ENABLED=$(OCC app:enable "$app")
		output "$APP_ENABLED"
		WAIT_TIME=0
		until [[ $WAIT_TIME -eq ${NEXTCLOUD_AUTOINSTALL_APPS_WAIT_TIME:-0} ]] || [[ $APP_ENABLED =~ ${app}.*enabled$ ]]
		do
			# if app is not installed pause for 1 seconds and enable again
			output "🔄 retrying"
			sleep 1
			APP_ENABLED=$(OCC app:enable "$app")
			output "$APP_ENABLED"
			((WAIT_TIME++))
		done
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

	TRUSTED_PROXY=$(ip a show type veth | awk '/scope global/ {print $2}')
	OCC config:system:set trusted_proxies 0 --value="$TRUSTED_PROXY"

	configure_ssl_proxy

	output "🔧 Preparing cron job"

	OCC dav:sync-system-addressbook

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

	run_hook_after_install

	output "🚀 Finished setup using $SQL database…"
}

run_hook_before_install() {
	[ -e /shared/hooks/before-install.sh ] && bash /shared/hooks/before-install.sh
}

run_hook_after_install() {
	[ -e /shared/hooks/after-install.sh ] && bash /shared/hooks/after-install.sh
}

run_hook_before_start() {
	[ -e /shared/hooks/before-start.sh ] && bash /shared/hooks/before-start.sh
}

run_hook_after_start() {
	[ -e /shared/hooks/after-start.sh ] && bash /shared/hooks/after-start.sh
}

add_hosts() {
	echo "Add the host IP as host.docker.internal to /etc/hosts ..."
	ip -4 route list match 0/0 | awk '{print $3 "   host.docker.internal"}' >> /etc/hosts
}

setup() {
	update_permission
	configure_xdebug_mode

	if is_installed || [[ ! -f $WEBROOT/config/config.php ]]
	then
		output "🚀 Nextcloud already installed ... skipping setup"

		# configuration that should be applied on each start
		configure_ssl_proxy
	else
		# We copy the default config to the container
		cp /root/default.config.php "$WEBROOT"/config/config.php
		chown -R www-data:www-data "$WEBROOT"/config/config.php

		mkdir -p "$WEBROOT/apps-extra"
		mkdir -p "$WEBROOT/apps-shared"

		update_permission

		if [ "$NEXTCLOUD_AUTOINSTALL" != "NO" ]
		then
			add_hosts
			install
		else
			touch "${WEBROOT}/config/CAN_INSTALL"
		fi
	fi
}
check_source() {
	FILE=/var/www/html/status.php
	if [ -f "$FILE" ]; then
		output "Server source is mounted, continuing"
	else
		# Only autoinstall when not running in docker compose
		if [ -n "$VIRTUAL_HOST" ] && [ ! -f "$WEBROOT"/version.php ]
		then
			output "======================================================================================="
			output " 🚨 Could not find a valid Nextcloud source in $WEBROOT                                "
			output " Double check your REPO_PATH_SERVER and STABLE_ROOT_PATH environment variables in .env "
			output "======================================================================================="

			exit 1
		fi

		output "Server source is not present, fetching ${SERVER_BRANCH:-master}"
		git clone --depth 1 --branch "${SERVER_BRANCH:-master}" https://github.com/nextcloud/server.git /tmp/server
		(cd /tmp/server && git submodule update --init)
		output "Cloning additional apps"
		git clone --depth 1 --branch "${SERVER_BRANCH:-master}" https://github.com/nextcloud/viewer.git /tmp/server/apps/viewer

		# shallow clone of submodules https://stackoverflow.com/questions/2144406/how-to-make-shallow-git-submodules
		git config -f .gitmodules submodule.3rdparty.shallow true
		(cd /tmp/server && git submodule update --init)
		rsync -a --chmod=755 --chown=www-data:www-data /tmp/server/ /var/www/html
		chown www-data: /var/www/html
		chown www-data: /var/www/html/.htaccess
	fi
	output "Nextcloud server source is ready"
}

(
	check_source
	wait_for_other_containers
	setup
	run_hook_before_start
	rm /etc/apache2/conf-enabled/install.conf
	rm -f /var/www/html/installing.html
	pkill -USR1 apache2
	run_hook_after_start
) &

touch /var/log/cron/nextcloud.log "$WEBROOT"/data/nextcloud.log /var/log/xdebug.log
chown www-data /var/log/xdebug.log

echo "📰 Watching log file"
tail --follow "$WEBROOT"/data/nextcloud.log /var/log/cron/nextcloud.log /var/log/xdebug.log &

echo "⌚ Starting cron"
/usr/sbin/cron -f &
echo "🚀 Starting apache"
exec "$@"
