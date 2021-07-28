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

## Getting started

To get the setup running:

```
git clone https://github.com/juliushaertl/nextcloud-docker-dev
cd nextcloud-docker-dev
./bootstrap.sh
sudo sh -c "echo '127.0.0.1 nextcloud.local' >> /etc/hosts"
docker-compose up nextcloud proxy
```

## Manual setup

### Nextcloud Code

The Nextcloud code base needs to be available including the `3rdparty` submodule. To clone it from github run:

```
git clone https://github.com/nextcloud/server.git
cd server
git submodule update --init
pwd
```
The last command prints the path to the Nextcloud server directory.
Use it for setting the `REPO_PATH_SERVER` in the next step.

### Environment variables

A `.env` file should be created in the repository root, to keep configuration default on the dev setup:

```
cp example.env .env
```

Replace `REPO_PATH_SERVER` with the path from above.

### Setting the PHP version to be used

The Nextcloud instance is setup to run with PHP 7.2 by default.
If you wish to use a different version of PHP, set the `PHP_VERSION` `.env` variable.

The variable supports the following values:

1. PHP 7.1: `71`
1. PHP 7.2: `72`
1. PHP 7.3: `73`
1. PHP 7.4: `74`

### Starting the containers

- Start full setup: `docker-compose up`
- Minimum: `docker-compose up proxy nextcloud` (nextcloud mysql redis mailhog)

### Switching to different env settings

This can be useful if you wish to run different setups besides each other:

```
docker-compose --env-file stable15.env up proxy nextcloud
```

Besides that there are also stable containers now in the main
`docker-compose.yml` file, which makes it a bit easier to run them side by
side. However the source location needs to be adjusted for this.

### Running into errors

If your setup isn't working and you can not figure out the reason why, running
`docker-compose down -v` will remove the relevant containers and volumes,
allowing you to run `docker-compose up` again from a clean slate.

## 🔒 Reverse Proxy

Used for SSL termination. To setup SSL support provide a proper DOMAIN_SUFFIX environment variable and put the certificates to ./data/ssl/ named by the domain name.

You might need to add the domains to your `/etc/hosts` file:

```
127.0.0.1 nextcloud.local
127.0.0.1 collabora.local
```

This is assuming you have set `DOMAIN_SUFFIX=.local`

You can generate selfsigned certificates using:

```
cd data/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  nextcloud.local.key -out nextcloud.local.crt
```

### Use valid certificates trusted by your system

* Install mkcert https://github.com/FiloSottile/mkcert
* Go to `data/ssl`
* `mkcert nextcloud.local`

* `mv nextcloud.local-key.pem nextcloud.local.key`
* `mv nextcloud.local.pem nextcloud.local.crt`
* `docker-compose restart proxy`

## ✉ Mail

Sending/receiving mails can be tested with [mailhog](https://github.com/mailhog/MailHog) which is available on ports 1025 (SMTP) and 8025 (HTTP).

## 🚀 Blackfire

Blackfire needs to use a hostname/ip that is resolvable from within the blackfire container. Their free version is [limited to local profiling](https://support.blackfire.io/troubleshooting/hack-edition-users-cannot-profile-non-local-http-applications) so we need to browse Nextcloud though its local docker IP or add the hostname to `/etc/hosts`.

### Using with curl

```
alias blackfire='docker-compose exec -e BLACKFIRE_CLIENT_ID=$BLACKFIRE_CLIENT_ID -e BLACKFIRE_CLIENT_TOKEN=$BLACKFIRE_CLIENT_TOKEN blackfire blackfire'
blackfire curl http://192.168.21.8/
```

## 👥 LDAP

The LDAP sample data is based on https://github.com/rroemhild/docker-test-openldap and extended with randomly generated users/groups. For details see [data/ldap-generator/](https://github.com/juliushaertl/nextcloud-docker-dev/tree/master/data/ldap-generator). LDAP will be configured automatically if the ldap container is available during installation.

Example users are: `leela fry bender zoidberg hermes professor`. The password is the same as the uid.

## Collabora

- set `'overwriteprotocol' => 'https'` to make sure proper URLs are handed over to collabora

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
## Fulltextsearch

```
docker-compose up -d elasticsearch
```

`sudo sysctl -w vm.max_map_count=262144`

## 🚧 Object storage

## Development

### OCC

Run inside of the Nextcloud container:
```
set XDEBUG_CONFIG=idekey=PHPSTORM
sudo -E -u www-data php -dxdebug.remote_host=192.168.21.1 occ
```

### Useful commands

- Restart apache: `docker-compose kill -s USR1 nextcloud`
