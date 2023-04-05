# nextcloud-dev-docker-compose

Nextcloud development environment using docker-compose

⚠ **DO NOT USE THIS IN PRODUCTION** Various settings in this setup are considered insecure and default passwords and secrets are used all over the place

Features

- ☁ Nextcloud
- 🔒 Nginx proxy with SSL termination
- 💾 MySQL
- 💡 Redis
- 👥 LDAP with example user data
- ✉ Mailhog
- 🚀 Blackfire
- 📄 Collabora


## Standalone containers

::: tip
This is a very simple way but doesn't cover all features. If you are looking for a fully featured setup you may skip to the next section
:::

There is a standalone version of the Nextcloud containers available that can be used to run Nextcloud without the other services. This is useful if you are just wanting to get started with app development against a specific server version, or to just have a quick way to develop, test or debug.

These containers support automatic fetching of the server source code and use SQLite as the database. The server source code is fetched from the official Nextcloud server repository and the version can be specified using the `NEXTCLOUD_VERSION` environment variable. The default version is `master`.

Running the containers does not need this repository to be cloned.

Example for running a Nextcloud server from the master branch of server:

```bash
docker run --rm -p 8080:80 ghcr.io/juliushaertl/nextcloud-dev-php80:latest
```

For app development you can mount your app directly into the container:

```bash
docker run --rm -p 8080:80 -v ~/path/to/appid:/var/www/html/apps-extra/appid ghcr.io/juliushaertl/nextcloud-dev-php80:latest
```

The `SERVER_BRANCH` environment variable can be used to run different versions of Nextcloud by specificing either a server branch or git tag.

```bash
docker run --rm -p 8080:80 -e SERVER_BRANCH=v24.0.1 ghcr.io/juliushaertl/nextcloud-dev-php80:latest
```

You can also mount your local server source code into the container to run a local version of Nextcloud:

```bash
docker run --rm -p 8080:80 -e SERVER_BRANCH=v24.0.1 -v /tmp/server:/var/www/html ghcr.io/juliushaertl/nextcloud-dev-php80:latest
```
## Simple master setup

The easiest way to get the setup running the ```master``` branch is by running the ```bootstrap.sh``` script:
```
git clone https://github.com/juliushaertl/nextcloud-docker-dev
cd nextcloud-docker-dev
./bootstrap.sh
sudo sh -c "echo '127.0.0.1 nextcloud.local' >> /etc/hosts"
docker-compose up nextcloud proxy
```
Note that for performance reasons the server repository might have been cloned with --depth=1 by default. To get the full history it is highly recommended to run:

	cd workspace/server
	git fetch --unshallow
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin

This may take some time depending on your internet connection speed.

## Additional apps

To install additional apps add them to the bootstrap command:

```bash
./bootstrap.sh circles contacts
```

You can also do this after the initial bootstrap.
In this case it will clone the apps but not update the `.env` file.
If you want your apps to be installed in the Nextcloud instance by default
add them to the `NEXTCLOUD_AUTOINSTALL_APPS` variable in `.env`.

## Complex setup

In order to achieve a more complex dev environment with different branches of the server, follow the manual steps:

##### 1. Clone the repository

```
git clone https://github.com/nextcloud/server.git
```

##### 2. The Nextcloud code base needs to be available including the [`3rdparty`](https://github.com/nextcloud/3rdparty) submodule:

```
cd server
git submodule update --init
pwd
```

The last command prints the path to the Nextcloud server directory.
Use it for setting the `REPO_PATH_SERVER` in the next step.

##### 3. Environment variables

A `.env` file should be created in the repository root, to keep configuration default on the dev setup:

```
cp example.env .env
```

Replace `REPO_PATH_SERVER` with the path from above.

##### 4. Running different stable versions

The docker-compose file provides individual containers for stable Nextcloud releases. In order to run those you will need a checkout of the stable version server branch to your workspace directory. Using [git worktree](https://blog.juliushaertl.de/index.php/2018/01/24/how-to-checkout-multiple-git-branches-at-the-same-time/) makes it easy to have different branches checked out in parallel in separate directories.

```
cd workspace/server
git worktree add ../stable23 stable23
```
As in the `server` folder, the `3rdparty` submodule is needed:
```
cd ../stable23
git submodule update --init
```

The same can be done for `stable24`, `stable25`... and so on. 

Git worktrees can also be used to have a checkout of an apps stable branch within the server stable directory.

```
cd workspace/server/apps-extra/text
git worktree add ../../../stable23/apps-extra/text stable23
```

Since the viewer app is kind of required for Nextcloud server, you should also add that to the stable worktrees:

```
cd workspace/server/apps/viewer
git worktree add ../../../stable25/apps/viewer stable25
```

##### 5. Editing `/etc/hosts`

You can then add `stable23.local`, `stable24.local` and so on to your `/etc/hosts` file to access it.
```
sudo sh -c "echo '127.0.0.1 nextcloud.local' >> /etc/hosts"
```

##### 6. Setting the PHP version to be used

The Nextcloud instance is setup to run with PHP 7.2 by default.
If you wish to use a different version of PHP, set the `PHP_VERSION` `.env` variable.

The variable supports the following values:

- PHP 7.1: `71`
- PHP 7.2: `72`
- PHP 7.3: `73`
- PHP 7.4: `74`
- PHP 8.0: `80`

##### 7. Starting the containers

- Minimum to run `master`: `docker-compose up proxy nextcloud` (nextcloud mysql redis mailhog)
- Start stable branches: `docker-compose up stable23 proxy`
- Start full setup: `docker-compose up`

##### 8. Switching between stable versions and master

Remove all relevant containers and volumes:
`docker-compose down -v`

Start master or the branch you want to run:
`docker-compose up stable23 proxy`

## Running into errors

- If your setup isn't working and you can not figure out the reason why, running
`docker-compose down -v` will remove the relevant containers and volumes,
allowing you to run `docker-compose up` again from a clean slate.

- Sometimes it might help: `docker pull ghcr.io/juliushaertl/nextcloud-dev-php74:latest`

- In extreme cases, clean everything: `docker system prune --all`

- If you start your stable containers (not the master) and it wants to install Nextcloud even if it is not the first start, you may have removed the configuration with the last `docker-compose down` command. Try to use `docker-compose stop` instead or give the stable setup named values yourself.

## 🔒 Reverse Proxy

Used for SSL termination. To setup SSL support provide a proper `DOMAIN_SUFFIX` environment variable and put the certificates to `./data/ssl/` named by the domain name.

You might need to add the domains to your `/etc/hosts` file:

```
127.0.0.1 nextcloud.local
127.0.0.1 collabora.local
```

This is assuming you have set `DOMAIN_SUFFIX=.local`

To update the hosts file automatically you can use the `update-hosts` script:

```
./scripts/update-hosts
```

You can generate self-signed certificates using:

```
cd data/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  nextcloud.local.key -out nextcloud.local.crt
```

You can also override the default port used for HTTP and HTTPS bound on the host for the proxy by setting these environment variables in the `.env` file (don't forget to recreate the containers):

```
PROXY_PORT_HTTP=8080
PROXY_PORT_HTTPS=4443
```

### dnsmasq to resolve wildcard domains

Instead of adding the individual container domains to `/etc/hosts` a local dns server like dnsmasq can be used to resolve any domain ending with the configured `DOMAIN_SUFFIX` in `.env` to localhost.

For dnsmasq adding the following configuration would be sufficient for `DOMAIN_SUFFIX=.local`:
```
address=/.local/127.0.0.1
```

### Use valid certificates trusted by your system

* Install [mkcert](https://github.com/FiloSottile/mkcert)
* Go to `data/ssl`
* `mkcert nextcloud.local`

* `mv nextcloud.local-key.pem nextcloud.local.key`
* `mv nextcloud.local.pem nextcloud.local.crt`
* `docker-compose restart proxy`

## ✉ Mail

Sending/receiving mail can be tested with [mailhog](https://github.com/mailhog/MailHog) which is available on ports 1025 (SMTP).

To use the webui, add `127.0.0.1 mail.local` to your `/etc/hosts` and open [mail.local](http://mail.local).

## 🚀 Blackfire

Blackfire needs to use a hostname/ip that is resolvable from within the Blackfire container. Their free version is [limited to local profiling](https://support.blackfire.io/troubleshooting/hack-edition-users-cannot-profile-non-local-http-applications) so we need to browse Nextcloud though its local docker IP or add the hostname to `/etc/hosts`.

By default the PHP module for Blackfire is disabled, but you can enable or disable this through the following script:

```
./scripts/php-mod-config nextcloud blackfire on
```

After that you can use Blackfire through the browser plugin or curl as described below.

### Using with curl

```
alias blackfire='docker-compose exec -e BLACKFIRE_CLIENT_ID=$BLACKFIRE_CLIENT_ID -e BLACKFIRE_CLIENT_TOKEN=$BLACKFIRE_CLIENT_TOKEN blackfire blackfire'
blackfire curl http://192.168.21.8/
```

## Xdebug

Xdebug is shipped but disabled by default. It can be turned on by running:

```
./scripts/php-mod-config nextcloud xdebug.mode debug
```

## 👥 LDAP

The LDAP sample data is based on https://github.com/rroemhild/docker-test-openldap and extended with randomly generated users/groups. For details see [data/ldap-generator/](https://github.com/juliushaertl/nextcloud-docker-dev/tree/master/data/ldap-generator). LDAP will be configured automatically if the ldap container is available during installation.

Example users are: `leela fry bender zoidberg hermes professor`. The password is the same as the uid.

Useful commands:

```
docker-compose exec ldap ldapsearch -H 'ldap://localhost' -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" "(&(objectclass=inetOrgPerson)(description=*use*))"
```

## Collabora

- Make sure to have the Collabora hostname setup in your `/etc/hosts` file: `127.0.0.1 collabora.local`
- Automatically enable for one of your containers (e.g. the main `nextcloud` one):
	- Run `./scripts/enable-collabora nextcloud`
- Manual setup
	- Start the Collabora Online server in addition to your other containers `docker-compose up -d collabora`
	- Make sure you have the [richdocuments app](https://github.com/nextcloud/richdocuments) cloned to your `apps-extra` directory and built the frontend code of the app with `npm ci && npm run build`
	- Enable the app and configure `collabora.local` in the Collabora settings inside of Nextcloud


## ONLYOFFICE

- Make sure to have the Collabora hostname setup in your `/etc/hosts` file: `127.0.0.1 onlyoffice.local`
- Automatically enable for one of your containers (e.g. the main `nextcloud` one):
	- Run `./scripts/enable-onlyoffice nextcloud`
- Manual setup
	- Start the ONLYOFFICE server in addition to your other containers `docker-compose up -d onlyoffice`
	- Clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud into your apps directory
	- Enable the app and configure `onlyoffice.local` in the ONLYOFFICE settings inside of Nextcloud


## Antivirus

```bash
docker-compose up -d proxy nextcloud av
```

The [ClamAV](https://www.clamav.net/) antivirus will then be exposed as a daemon with host `clam` and
port `3310`.

## SAML

```
docker-compose up -d proxy nextcloud saml
```

- uid mapping: `urn:oid:0.9.2342.19200300.100.1.1`
- idp entity id: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/metadata.php`
- Single Sign-On (SSO) service url: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/SSOService.php`
- single log out service url: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/SingleLogoutService.php`
- use certificate from `docker/configs/var-simplesamlphp/cert/example.org.crt`
  ```
  -----BEGIN CERTIFICATE-----
  MIICrDCCAhWgAwIBAgIUNtfnC2jE/rLdxHCs2th3WaYLryAwDQYJKoZIhvcNAQEL
  BQAwaDELMAkGA1UEBhMCREUxCzAJBgNVBAgMAkJZMRIwEAYDVQQHDAlXdWVyemJ1
  cmcxFDASBgNVBAoMC0V4YW1wbGUgb3JnMSIwIAYDVQQDDBlzc28ubG9jYWwuZGV2
  LmJpdGdyaWQubmV0MB4XDTE5MDcwMzE0MjkzOFoXDTI5MDcwMjE0MjkzOFowaDEL
  MAkGA1UEBhMCREUxCzAJBgNVBAgMAkJZMRIwEAYDVQQHDAlXdWVyemJ1cmcxFDAS
  BgNVBAoMC0V4YW1wbGUgb3JnMSIwIAYDVQQDDBlzc28ubG9jYWwuZGV2LmJpdGdy
  aWQubmV0MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHPZwU+dAc76yB6bOq
  0AkP1y9g7aAi1vRtJ9GD4AEAsA3zjW1P60BYs92mvZwNWK6NxlJYw51xPak9QMk5
  qRHaTdBkmq0a2mWYqh1AZNNgCII6/VnLcbEIgyoXB0CCfY+2vaavAmFsRwOMdeR9
  HmtQQPlbTA4m5Y8jWGVs1qPtDQIDAQABo1MwUTAdBgNVHQ4EFgQUeZSoGKeN5uu5
  K+n98o3wcitFYJ0wHwYDVR0jBBgwFoAUeZSoGKeN5uu5K+n98o3wcitFYJ0wDwYD
  VR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOBgQA25X/Ke+5dw7up8gcF2BNQ
  ggBcJs+SVKBmPwRcPQ8plgX4D/K8JJNT13HNlxTGDmb9elXEkzSjdJ+6Oa8n3IMe
  vUUejXDXUBvlmmm+ImJVwwCn27cSfIYb/RoZPeKtned4SCzpbEO9H/75z3XSqAZS
  Z1tiHzYOVtEs4UNGOtz1Jg==
  -----END CERTIFICATE-----
  ```
- cn `urn:oid:2.5.4.3`
- email `urn:oid:0.9.2342.19200300.100.1.3`

### Environment-based SSO

A simple approach to test environment-based SSO with the `user_saml` app is to use Apache's basic auth with the following configuration:

```

<Location /login>
	AuthType Basic
	AuthName "SAML"
	AuthUserFile /var/www/html/.htpasswd
	Require valid-user
</Location>
<Location /index.php/login>
	AuthType Basic
	AuthName "SAML"
	AuthUserFile /var/www/html/.htpasswd
	Require valid-user
</Location>
<Location /index.php/apps/user_saml/saml/login>
	AuthType Basic
	AuthName "SAML"
	AuthUserFile /var/www/html/.htpasswd
	Require valid-user
</Location>
<Location /apps/user_saml/saml/login>
	AuthType Basic
	AuthName "SAML"
	AuthUserFile /var/www/html/.htpasswd
	Require valid-user
</Location>
```

## [Fulltextsearch](https://github.com/nextcloud/fulltextsearch)

```
docker-compose up -d elasticsearch elasticsearch-ui
```

- Address for configuring in Nextcloud: `http://elastic:elastic@elasticsearch:9200`
- Address to access Elasticsearch from outside: `http://elastic:elastic@elasticsearch.local`
- Address for accessing the UI: http://elasticsearch-ui.local/

`sudo sysctl -w vm.max_map_count=262144`



## Object storage

Primary object storage can be enabled by setting the `PRIMARY=minio` environment variable either in your `.env` file or in `docker-compose.yml` for individual containers.

```bash
docker-compose up proxy nextcloud minio
```

## Development

### OCC

Run inside of the Nextcloud container:
```
set XDEBUG_CONFIG=idekey=PHPSTORM
sudo -E -u www-data php -dxdebug.remote_host=192.168.21.1 occ
```

### Useful commands

- Restart Apache to reload php configuration without a full container restart: `docker-compose kill -s USR1 nextcloud`
- Access to MySQL console: `mysql -h $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_database-mysql_1) -P 3306 -u nextcloud -pnextcloud`
- Run an LDAP search: `ldapsearch -x -H ldap://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_ldap_1) -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" -s subtree <filter> <attrs>`

## [Keycloak}(https://www.keycloak.org/)

- Keycloak is using LDAP as a user backend (make sure the LDAP container is also running)
- `occ user_oidc:provider Keycloak -c nextcloud -s 09e3c268-d8bc-42f1-b7c6-74d307ef5fde -d http://keycloak.dev.local/auth/realms/Example/.well-known/openid-configuration`
- http://keycloak.dev.local/auth/realms/Example/.well-known/openid-configuration
- nextcloud
- 09e3c268-d8bc-42f1-b7c6-74d307ef5fde

## Global scale

```
docker-compose up -d proxy portal gs1 gs2 lookup database-mysql
```

Users are named the same as the instance name, e.g. `gs1`, `gs2`

## Imaginary

Enable the imaginary server for generating previews

```bash
docker-compose up proxy nextcloud previews_hpb
./scripts/enable-preview-imaginary.sh
```

## PhpMyAdmin
If you need to access the database, you can startup the `phpmyadmin` container that is already prepared.
```
docker-compose up -d phpmyadmin
```
Just add the domain to your `/etc/hosts` file and give it a try.

```
sudo sh -c "echo '127.0.0.1 phpmyadmin.local' >> /etc/hosts"
```

## pgAdmin
If you need to access the database and you are running PostgreSQL, you can use this additional container.

```
docker-compose up -d pgadmin
```

Add the domain to your `/etc/hosts` file:

```
sudo sh -c "echo '127.0.0.1 pgadmin.local' >> /etc/hosts"
```

After you have started the container open `pgadmin.local` in a web browser. The password for the `nextcloud.local` is `postgres`.
That's it, open the following path to see the Nextcloud tables: `Server group 1 -> nextcloud.local -> Databases -> nextcloud -> Schemas -> public -> Tables`
