# Xdebug

Xdebug is shipped but disabled by default. It can be turned on by running:

```
./scripts/php-mod-config nextcloud xdebug.mode debug
```

You can also enable other modes, e.g. trace:

```
./scripts/php-mod-config nextcloud xdebug.mode debug,trace
```

### Debugging cron, occ or other command line scripts

```
docker compose exec nextcloud bash
# use this if you have configured path mapping in PHPstorm to match the server name configured
export PHP_IDE_CONFIG=serverName=localhost
sudo -E -u www-data php -dxdebug.mode=debug -dxdebug.client_host=host.docker.internal -dxdebug.start_with_request=yes -dxdebug.idekey=PHPSTORM occ
```
