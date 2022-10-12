# 🚀 Blackfire

Blackfire needs to use a hostname/ip that is resolvable from within the blackfire container. Their free version is [limited to local profiling](https://support.blackfire.io/troubleshooting/hack-edition-users-cannot-profile-non-local-http-applications) so we need to browse Nextcloud though its local docker IP or add the hostname to `/etc/hosts`.

## Using with curl

```
alias blackfire='docker compose exec -e BLACKFIRE_CLIENT_ID=$BLACKFIRE_CLIENT_ID -e BLACKFIRE_CLIENT_TOKEN=$BLACKFIRE_CLIENT_TOKEN blackfire blackfire'
blackfire curl http://192.168.21.8/
```
