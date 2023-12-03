# Database

## Introduction

By default MySQL will be used as database backend. You can change this by setting the `SQL` variable in the `.env` file. The following databases are supported:

- `mysql`
- `pgsql`
- `sqlite`
- `mariadb-replica`
- `maxscale`

Changing the database env value will require to recreate your setup. You can do this by running `docker-compose down -v` and then `docker-compose up -d nextcloud`.

All databases use the following credentials by default:
- Root password: `nextcloud`
- Username: `nextcloud`
- Password: `nextcloud`
- Database: `nextcloud` or the name of the stable container e.g. `stable27``


## Accessing the database

### MySQL/MariaDB

You can access the database with the following command:

```bash
docker-compose exec mariadb mysql -u root -pnextcloud
```

If you prefer a GUI frontend you can additionally launch the phpmyadmin container with `docker-compose up -d phpmyadmin` and access it via http://phpmyadmin.local.

Alternatively you can use a database client to access the database from the host system. The port can be obtained with `docker-compose port database-mysql 3306`. The host is `localhost` and the credentials are the same as above.

### PostgreSQL

You can access the database with the following command:

```bash
docker-compose exec postgres psql -U nextcloud -d nextcloud
```

If you prefer a GUI frontend you can additionally launch the pgadmin container with `docker-compose up -d pgadmin` and access it via http://pgadmin.local.

Alternatively you can use a database client to access the database from the host system. The port can be obtained with `docker-compose port database-postgresql 5432`. The host is `localhost` and the credentials are the same as above.

### SQLite

You can access the database with the following command:

```bash
docker-compose exec nextcloud sqlite3 /var/www/html/data/nextcloud.db
```

### MariaDB Replica

This mode runs a mariadb primary and read replica setup. The primary is used for writes and the replica for reads. This is useful for larger setups where you want to scale the database.

You can access the database with the following command:

```bash
docker-compose exec database-mariadb-primary mysql -u root -pnextcloud
docker-compose exec database-mariadb-replica mysql -u root -pnextcloud
```

### MaxScale

This mode runs a mariadb primary and read replica setup with maxscale as load balancer. The primary is used for writes and the replica for reads where MaxScale is used to perform a read-write-split.

The logs of MaxScale can be accessed with `docker-compose exec maxscale cat /var/log/maxscale/maxscale.log`.