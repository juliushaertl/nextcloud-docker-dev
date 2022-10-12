# Mysql

This is information about the mysql service :

- password roor : `nextcloud`

- user : `nextcloud`
- password : `nextcloud`

- database name : `nextcloud`

## How to connect on the mysql service ?

First, found the name of your container :

```bash
$ docker compose ps
NAME                           COMMAND                  SERVICE             STATUS              PORTS
nextcloud-database-mysql-1     "docker-entrypoint.s…"   database-mysql      running             0.0.0.0:8212->3306/tcp, :::8212->3306/tcp
nextcloud-elasticsearch-1      "/bin/tini -- /usr/l…"   elasticsearch       running             9200/tcp, 9300/tcp
nextcloud-elasticsearch-ui-1   "docker-entrypoint.s…"   elasticsearch-ui    running             0.0.0.0:1358->1358/tcp, :::1358->1358/tcp
nextcloud-ldap-1               "/container/tool/run…"   ldap                running             636/tcp, 0.0.0.0:3389->389/tcp, :::3389->389/tcp
nextcloud-mail-1               "MailHog"                mail                running             1025/tcp, 8025/tcp
nextcloud-minio-1              "/usr/bin/docker-ent…"   minio               running             9000/tcp
nextcloud-nextcloud-1          "/usr/local/bin/boot…"   nextcloud           running             0.0.0.0:8210->80/tcp, :::8210->80/tcp
nextcloud-proxy-1              "/app/docker-entrypo…"   proxy               running             0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp
nextcloud-redis-1              "docker-entrypoint.s…"   redis               running             6379/tcp
```

For me, it's `nextcloud-database-mysql-1`.

Then, you can connect on the container with this command :

```bash
docker exec -it  nextcloud-database-mysql-1 /bin/bash
```

Finally, use this command to connect on the database :

```bash
mysql -u nextcloud -p
```

It has to input the password. The password to enter in Mysql is `nextcloud`.