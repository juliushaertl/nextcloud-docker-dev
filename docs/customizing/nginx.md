# Customize nginx config

## Add custom config for a virtualhost config

Add a config snippet to `data/nginx/vhost.d/<vhost-name>`, it will be included in the respective vhost config automatically.

For example to redirect all requests to `/apps.*/text` to a `vite serve` process on the docker host, add the following to `data/nginx/vhost.d/nextcloud.local`:

```
location ~* ^/apps.*/text/ {
    rewrite ^/apps.*/text/(.*) /$1 break;
    proxy_pass http://host.docker.internal:5173;
    # fallback to nextcloud server if vite serve doesn't answer
    error_page 502 = @fallback;
}
location @fallback {
    proxy_pass http://nextcloud.local;
}
```
