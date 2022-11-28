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

## Complex setup

In order to achieve a more complex dev environment with different branches of the server, follow the manual steps:

##### 1. Clone the repository

```
git clone https://github.com/nextcloud/server.git
```

##### 2. The Nextcloud code base needs to be available including the `3rdparty` submodule:

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
As in the in the `server` folder, the `3rdparty` submodule is needed:
```
cd ../stable23
git submodule update --init
```

The same can be done for stable24, stable25... and so on. 

Git worktrees can also be used to have a checkout of an apps stable brach within the server stable directory.

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

You can then add stable23.local, stable24.local and so on to your `/etc/hosts` file to access it.
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

## 🔒 Reverse Proxy

Used for SSL termination. To setup SSL support provide a proper DOMAIN_SUFFIX environment variable and put the certificates to ./data/ssl/ named by the domain name.

You might need to add the domains to your `/etc/hosts` file:

```
127.0.0.1 nextcloud.local
127.0.0.1 collabora.local
```

This is assuming you have set `DOMAIN_SUFFIX=.local`

You can generate it through:

```
awk -v D=.local '/- [A-z0-9]+\${DOMAIN_SUFFIX}/ {sub("\\$\{DOMAIN_SUFFIX\}", D " 127.0.0.1", $2); print $2}' docker-compose.yml
```

You can generate selfsigned certificates using:

```
cd data/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  nextcloud.local.key -out nextcloud.local.crt
```

### dnsmasq to resolve wildcard domains

Instead of adding the individual container domains to `/etc/hosts` a local dns server like dnsmasq can be used to resolve any domain ending with the configured DOMAIN_SUFFIX in `.env` to localhost.

For dnsmasq adding the following configuration would be sufficient for `DOMAIN_SUFFIX=.local`:
```
address=/.local/127.0.0.1
```

### Use valid certificates trusted by your system

* Install mkcert https://github.com/FiloSottile/mkcert
* Go to `data/ssl`
* `mkcert nextcloud.local`

* `mv nextcloud.local-key.pem nextcloud.local.key`
* `mv nextcloud.local.pem nextcloud.local.crt`
* `docker-compose restart proxy`

## ✉ Mail

Sending/receiving mails can be tested with [mailhog](https://github.com/mailhog/MailHog) which is available on ports 1025 (SMTP).

To use the webui, add `127.0.0.1 mail.local` to your `/etc/hosts` and open [mail.local](http://mail.local).

## 🚀 Blackfire

Blackfire needs to use a hostname/ip that is resolvable from within the blackfire container. Their free version is [limited to local profiling](https://support.blackfire.io/troubleshooting/hack-edition-users-cannot-profile-non-local-http-applications) so we need to browse Nextcloud though its local docker IP or add the hostname to `/etc/hosts`.

By default the PHP module for blackfire is disabled, but you can enable or disable this through the following script:

```
./scripts/php-mod-config nextcloud blackfire on
```

After that you can use blackfire through the browser plugin or curl as described below.

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

- Make sure to have the collabora hostname setup in your /etc/hosts file: `127.0.0.1 collabora.local`
- Automatically enable for one of your containers (e.g. the main nextcloud one):
	- Run `./scripts/enable-collabora nextcloud`
- Manual setup
	- Start the Collabora Online server in addition to your other containers `docker-compose up -d collabora`
	- Make sure you have the richdocuments app cloned to your apps-extra directory and built the frontend code of the app with `npm ci && npm run build`
	- Enable the app and configure `collabora.local` in the Collabora settings inside of Nextcloud


## ONLYOFFICE

- Make sure to have the collabora hostname setup in your /etc/hosts file: `127.0.0.1 onlyoffice.local`
- Automatically enable for one of your containers (e.g. the main nextcloud one):
	- Run `./scripts/enable-onlyoffice nextcloud`
- Manual setup
	- Start the ONLYOFFICE server in addition to your other containers `docker-compose up -d onlyoffice`
	- Clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud into your apps directory
	- Enable the app and configure `onlyoffice.local` in the ONLYOFFICE settings inside of Nextcloud


## Antivirus

```bash
docker-compose up -d proxy nextcloud av
```

The clanav antivirus will then be exposed as a deamon with host `clam` and
port 3310.

## SAML

```
docker-compose up -d proxy nextcloud saml
```

- uid mapping: `urn:oid:0.9.2342.19200300.100.1.1`
- idp entity id: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/metadata.php`
- single sign on service url: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/SSOService.php`
- single log out service url: `https://sso.local.dev.bitgrid.net/simplesaml/saml2/idp/SingleLogoutService.php`
- use certificate from docker/configs/var-simplesamlphp/cert/example.org.crt
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

### Environment based SSO

A simple approach to test environment based SSO with the user_saml app is to use apache basic auth with the following configuration:

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

## Fulltextsearch

```
docker-compose up -d elasticsearch elasticsearch-ui
```

- Address for configuring in Nextcloud: `http://elastic:elastic@elasticsearch:9200`
- Adress to access elastic search from outside: `http://elastic:elastic@elasticsearch.local`
- Address for accessing the ui: http://elasticsearch-ui.local/

`sudo sysctl -w vm.max_map_count=262144`



## Object storage

Primary object storage can be enabled by setting the `PRIMARY=minio` environment variable either in your .env file or in docker-compose.yml for individual containers.

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

- Restart apache to reload php configuration without a full container restart: `docker-compose kill -s USR1 nextcloud`
- Access to mysql console: `mysql -h $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_database-mysql_1) -P 3306 -u nextcloud -pnextcloud`
- Run an LDAP search: `ldapsearch -x -H ldap://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_ldap_1) -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" -s subtree <filter> <attrs>`

## Keycloak

- Keycloak is using ldap as a user backend (make sure the ldap container is also running)
- `occ user_oidc:provider Keycloak -c nextcloud -s 09e3c268-d8bc-42f1-b7c6-74d307ef5fde -d https://keycloak.local.dev.bitgrid.net/auth/realms/Example/.well-known/openid-configuration`
- https://keycloak.local.dev.bitgrid.net/auth/realms/Example/.well-known/openid-configuration
- nextcloud
- 09e3c268-d8bc-42f1-b7c6-74d307ef5fde

## Global scale

```
docker-compose up -d proxy portal gs1 gs2 lookup database-mysql
```

Users are named the same as the instance name, e.g. gs1, gs2

## Imaginary

Enable the imaginary server for generating previews

```bash
docker-compose up proxy nextcloud previews_hpb
./scripts/enable-preview-imaginary.sh
```


