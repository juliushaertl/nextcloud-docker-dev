#!/bin/bash

set -o errexit
set -o nounset

indent() {
	sed 's/^/    /'
}

indent_cli() {
	sed -u 's/^/   > /'
}

function install_app() {
	(
		echo "🌏 Fetching $1"
		(git clone https://github.com/nextcloud/$1.git workspace/server/apps-extra/$1 2>&1 | indent_cli &&
			echo "✅ $1 installed") ||
			echo "❌ Failed to install $1"
	) | indent
}

function is_installed() {
	(
		if [ -x "$(command -v $1)" ]; then
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
is_installed docker-compose
is_installed git

( 
	(docker ps 2>&1 >/dev/null && echo "✅ Docker is properly executable") ||
		(echo "❌ Cannot run docker ps, you might need to check that your user is able to use docker properly" && exit 1)
) | indent

echo
echo "⏩ Setting up folder structure and fetching repositories"

mkdir -p workspace/
( 
	(
		echo "🌏 Fetching server" &&
			git clone https://github.com/nextcloud/server.git workspace/server 2>&1 | indent_cli &&
			cd workspace/server && git submodule update --init 2>&1 | indent_cli
	) || echo "❌ Failed to clone Nextcloud server code"
) | indent

(
	(
		cd workspace/server && \
		git worktree add ../stable19 stable19 2>&1 | indent_cli
	) || echo "❌ Failed to setup worktree for stable19"
) | indent

mkdir -p workspace/server/apps-extra
install_app viewer
install_app recommendations
install_app files_pdfviewer

echo
echo
echo "⏩ Setup your environment in an .env file"
if [ ! -f ".env" ]; then
cat <<EOT >.env
COMPOSE_PROJECT_NAME=nextcloud
DOMAIN_SUFFIX=.local
REPO_PATH_SERVER=$PWD/workspace/server
ADDITIONAL_APPS_PATH=$PWD/workspace/server/apps-extra
NEXTCLOUD_AUTOINSTALL_APPS="viewer"
DOKER_SUBNET=192.168.21.0/24
PORTBASE=821
EOT
fi
cat <<EOF


 ╔═════════════════════════════════════════╗
 ║ oOo Ready to start developing 🎉        ║
 ╚═════════════════════════════════════════╝

 🚀  Start the Nextcloud server by running

	$ docker-compose up -d nextcloud


 💤  Stop it with

	$ docker-compose stop nextcloud


 🗑  Fresh install and wipe all data

	$ docker-compose down -v


For more details about the individual setup options see 
the README.md file or checkout the repo at
https://github.com/juliushaertl/nextcloud-docker-dev
EOF
