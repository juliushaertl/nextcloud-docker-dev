# HTTPS

A nginx proxy container is used to route requests to the correct container. This proxy is automatically started. It can be configured to use HTTPS by setting the `PROTOCOL` environment variable to `https` in the `.env` file. The container will pick up SSL certificates automatically from `data/ssl/` named by the domain name.

# Use mkcert

mkcert is a simple tool for making locally-trusted development certificates. It requires no configuration. This would be the recommended way to generate certificates for local development.

* Install [mkcert](https://github.com/FiloSottile/mkcert)
* Go to `data/ssl`
* `mkcert -cert-file nextcloud.local.crt -key-file nextcloud.local.key nextcloud.local`
* Add `PROTOCOL=https` to your `.env` file
* `docker-compose restart proxy`
* There is also a script to generate/update all certs: `./scripts/update-certs`

## Use self-signed certificates

You can generate self-signed certificates using:

```
cd data/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout  nextcloud.local.key -out nextcloud.local.crt
```
