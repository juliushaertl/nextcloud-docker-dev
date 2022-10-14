# Mysql

This is information about the mysql service :

- user root : `root`
- password root : `nextcloud`

- user : `nextcloud`
- password : `nextcloud`

- database name : `nextcloud`

## How to connect on the mysql service ?

You can run this command to be in the mysql prompt as no root :

```bash
docker compose exec database-mysql mysql -unextcloud -pnextcloud
```

If you want to be as root, use this command :

```bash
docker compose exec database-mysql mysql -uroot -pnextcloud
```