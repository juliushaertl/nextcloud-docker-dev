# 👥 LDAP

The LDAP sample data is based on https://github.com/rroemhild/docker-test-openldap and extended with randomly generated users/groups. For details see [data/ldap-generator/](https://github.com/juliushaertl/nextcloud-docker-dev/tree/master/data/ldap-generator). LDAP will be configured automatically if the ldap container is available during installation.


|uid (login) | password |
|---|---|
| leela | leela |
| fry | fry |
| zoidberg | zoidberg |
| hermes | hermes |
| professor | professor |
| ... | ... |


To add LDAP in your dev environment use these commands :

```bash
docker compose down -v
docker compose up nextcloud proxy ldap
```

You can add another services from `docker-compose.yaml` if you want.

Useful commands to know all LDAP's objects :

```
docker compose exec ldap ldapsearch -H 'ldap://localhost' -D "cn=admin,dc=planetexpress,dc=com" -w admin -b "dc=planetexpress,dc=com" "(&(objectclass=inetOrgPerson)(description=*use*))"
```