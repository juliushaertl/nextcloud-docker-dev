# SSL

## What is SSL ?

<!-- ## How to use this container with others ?-->
<!-- This section describes if there are particularities or others with this container. -->

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
* `docker compose restart proxy`