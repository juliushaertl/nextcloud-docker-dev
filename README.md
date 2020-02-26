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

### Environment variables

A `.env` file should be created in the repository root, to keep configuration default on the dev setup:

```
COMPOSE_PROJECT_NAME=master

REPO_PATH_SERVER=/home/jus/repos/nextcloud/server
ADDITIONAL_APPS_PATH=/home/jus/repos/nextcloud/server/apps-extra

NEXTCLOUD_AUTOINSTALL_APPS="viewer activity"

BLACKFIRE_CLIENT_ID=
BLACKFIRE_CLIENT_TOKEN=
BLACKFIRE_SERVER_ID=
BLACKFIRE_SERVER_TOKEN=

# can be used to run separate setups besides each other
DOCKER_SUBNET=192.168.15.0/24
PORTBASE=815

# Main dns names for ssl proxy
NEXTCLOUD_DOMAIN=nextcloud.local
COLLABORA_DOMAIN=collabora.local
```

### Starting the containers

- Start full setup: `docker-compose up`
- Minimum: `docker-compose up proxy nextcloud` (nextcloud mysql redis mailhog)

### Switching to different env settings

This can be useful if you wish to run different Nextcloud versions besides each other:

```
set -a; . stable15.env; set +a
docker-compose up proxy nextcloud
```

### Running into errors

If your setup isn't working and you can not figure out the reason why, running
`docker-compose down -v` will remove the relevant containers and volumes,
allowing you to run `docker-compose up` again from a clean slate.


## 🔒 Reverse Proxy

Used for SSL termination. To setup SSL support provide a proper NEXTCLOUD_DOMAIN environment variable and put the certificates to ./data/ssl/ named by the domain name.

You might need to add the domains to your `/etc/hosts` file:

```
127.0.0.1 nextcloud.local
127.0.0.1 collabora.local
```

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

Example ldif is generated using http://ldapwiki.com/wiki/LDIF%20Generator

LDAP can be setup by running the following command to autoprovision the config from data/ldap.json:

```
docker-compose exec nextcloud occ app:enable user_ldap

curl -X POST https://admin:admin@nextcloud.local/ocs/v2.php/apps/user_ldap/api/v1/config -H "OCS-APIREQUEST: true"

curl -X PUT https://admin:admin@nextcloud.local/ocs/v2.php/apps/user_ldap/api/v1/config/s01 -H "OCS-APIREQUEST: true" -d @data/ldap.json --header "Content-Type: application/json"

docker-compose exec nextcloud occ ldap:test-config s01
```

Example users are: `KerwinM SuwanawV WalkinsD DeluceL MaliepaM FabijanD ShiS HalpinM` The default password for all ldap users is `Password1`

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
## Fulltextsearch

```
docker-compose up -d elasticsearch
```

`sudo sysctl -w vm.max_map_count=262144`

## 🚧 Object storage

## Development

### OCC

Run inside of the nextcloud container:
```
set XDEBUG_CONFIG=idekey=PHPSTORM
sudo -E -u www-data php -dxdebug.remote_host=192.168.21.1 occ
```

