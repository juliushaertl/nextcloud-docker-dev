#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

APPS_TO_INSTALL=(viewer recommendations files_pdfviewer profiler hmr_enabler)
NEXTCLOUD_AUTOINSTALL_APPS=(viewer profiler hmr_enabler)

# You can specify additional apps to install on the command line.
APPS_TO_INSTALL+=( "$@" )
NEXTCLOUD_AUTOINSTALL_APPS+=( "$@" )

indent() {
	sed 's/^/    /'
}

indent_cli() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		sed -l 's/^/   > /'
	else
		sed -u 's/^/   > /'
	fi
}

function install_server() {
	if [ -d workspace/server/.git ]; then
		echo "🆗 Server is already installed." | indent
		return
	fi
	mkdir -p workspace/
	(
		(
			echo "🌏 Fetching server (this might take a while to finish)" &&
				git clone https://github.com/nextcloud/server.git --depth 1 workspace/server 2>&1 | indent_cli &&
				cd workspace/server && git submodule update --init 2>&1 | indent_cli
		) || echo "❌ Failed to clone Nextcloud server code"
	) | indent
}

function install_app() {
	TARGET=workspace/server/apps-extra/"$1"
	if [ -d "$TARGET"/.git ]; then
		echo "🆗 App $1 is already installed." | indent
		return
	fi
	(
		echo "🌏 Fetching $1"
		(git clone https://github.com/nextcloud/"$1".git "$TARGET" 2>&1 | indent_cli &&
			echo "✅ $1 installed") ||
			echo "❌ Failed to install $1"
	) | indent
}

function is_installed() {
	(
		if [ -x "$(command -v "$1")" ]; then
			echo "✅ $1 is properly installed"
		else
			echo "❌ Install $1 before running this script"
			exit 1
		fi
	) | indent
}

echo
echo "⏩ Performing system checks"

is_installed docker
is_installed git

(
	(docker ps 2>&1 >/dev/null && echo "✅ Docker is properly executable") ||
		(echo "❌ Cannot run docker ps, you might need to check that your user is able to use docker properly" && exit 1)
) | indent

echo
echo "⏩ Setting up folder structure and fetching repositories"
install_server
mkdir -p workspace/server/apps-extra
for app in "${APPS_TO_INSTALL[@]}"
do
	install_app "$app"
done


echo
echo
echo "⏩ Setup your environment in an .env file"
if [ ! -f ".env" ]; then
cat <<EOT >.env
COMPOSE_PROJECT_NAME=master
DOMAIN_SUFFIX=.local
REPO_PATH_SERVER=$PWD/workspace/server
STABLE_ROOT_PATH=$PWD/workspace
NEXTCLOUD_AUTOINSTALL_APPS="${NEXTCLOUD_AUTOINSTALL_APPS[@]}"
DOCKER_SUBNET=192.168.21.0/24
PORTBASE=821
PHP_XDEBUG_MODE=develop
# SQL variant to use, possible values: sqlite, mysql, pgsql
SQL=mysql
DB_SERVICE=database-mysql
# other values: "database-postgres"
EOT
fi

if [[ $(uname -m) == 'arm64' ]]; then
	echo "Setting custom containers for arm platform"

	echo "CONTAINER_ONLYOFFICE=onlyoffice/documentserver:latest-arm64" >> .env
	echo "CONTAINER_KEYCLOAK=mihaibob/keycloak:15.0.1" >> .env
fi

cat <<EOF


 ╔═════════════════════════════════════════╗
 ║ oOo Ready to start developing 🎉        ║
 ╚═════════════════════════════════════════╝

 🚀  Start the Nextcloud server by running

	$ docker compose up -d nextcloud


 💤  Stop it with

	$ docker compose stop nextcloud


 🗑  Fresh install and wipe all data

	$ docker compose down -v


	Note that for performance reasons the server repository has been cloned with
	--depth=1. To get the full history it is highly recommended to run:

	$ cd workspace/server
	$ git fetch --unshallow
	$ git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	$ git fetch origin

	This may take some time depending on your internet connection speed.


For more details about the individual setup options see
the README.md file or checkout the repo at
https://github.com/juliushaertl/nextcloud-docker-dev
EOF
