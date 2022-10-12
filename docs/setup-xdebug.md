## Development

### OCC

Run inside of the Nextcloud container:

```bash
set XDEBUG_CONFIG=idekey=PHPSTORM
sudo -E -u www-data php -dxdebug.remote_host=192.168.21.1 occ
```

### Useful commands

- Restart apache to reload php configuration without a full container restart: `docker compose kill -s USR1 nextcloud`
- Access to mysql console: `mysql -h $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_database-mysql_1) -P 3306 -u nextcloud -pnextcloud`
- Run an LDAP search: `ldapsearch -x -H ldap://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_ldap_1) -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" -s subtree <filter> <attrs>`
