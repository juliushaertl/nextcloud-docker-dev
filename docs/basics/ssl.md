# HTTPS

# Use valid certificates trusted by your system

* Install [mkcert](https://github.com/FiloSottile/mkcert)
* Go to `data/ssl`
* `mkcert -cert-file nextcloud.local.crt -key-file nextcloud.local.key nextcloud.local`
* `docker-compose restart proxy`
* There is also a script to generate/update all certs: `./scripts/update-certs`