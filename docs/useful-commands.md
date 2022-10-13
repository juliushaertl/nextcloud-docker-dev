# Useful commands


## Related to Apache

- Restart apache to reload php configuration without a full container restart: `docker compose kill -s USR1 nextcloud`


## Related to MySql

- Access to mysql console: `mysql -h $(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_database-mysql_1) -P 3306 -u nextcloud -pnextcloud`


## Related to LDAP

- Run an LDAP search: `ldapsearch -x -H ldap://$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nextcloud_ldap_1) -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" -s subtree <filter> <attrs>`
