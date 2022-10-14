# nextcloud-dev-docker-compose

Hi beginner developer ! 👋

This project allows you to start developing a Nextcloud app or contribute to Nextcloud server.

This project is very **modular** where you can add [features](#different-feature-you-can-use).
So, you can use this project for your development environment only.

⚠ **DO NOT USE THIS IN PRODUCTION** Various settings in this setup are considered insecure and default passwords and secrets are used all over the place.

If you don't know how to install Docker, please, read this tutorial by Daphne Muller: https://cloud.nextcloud.com/s/iyNGp8ryWxc7Efa
Be careful : Read the "README.md" of the tutorial written by Daphne Muller first.

## Table of Contents

1. [Getting started 🎮](#getting-started-🎮)
2. [First connection](#first-connection)
    * [Which user accounts can I use ?](#which-user-accounts-can-i-use)
3. [Where can I add my app for development ?](#where-can-i-add-my-app-for-development)
4. [Going further](#going-further)
    * [Different feature you can use](#different-feature-you-can-use)
        * [Nginx proxy with SSL termination](docs/containers/ssl.md)
        * [MySql](docs/containers/mysql.md)
        * [LDAP with example user data](docs/containers/ldap.md)
        * [Mailhog](docs/containers/mail.md)
        * [Blackfire](docs/containers/blackfire.md)
        * [Collabora](docs/containers/collabora.md)
        * [Only Office](docs/containers/onlyoffice.md)
        * [SAML](docs/containers/saml.md)
        * [Full Text Search](docs/containers/fulltextsearch.md)
        * [Object Storage](docs/containers/objectstorage.md)
        * [Antivirus](docs/containers/antivirus.md)
        * [Keycloak](docs/containers/keycloak.md)
        * [Global Scale](docs/containers/globalscale.md)
        * [Imaginary](docs/containers/imaginary.md)

## Getting started 🎮

First, get the setup running:

```bash
git clone https://github.com/juliushaertl/nextcloud-docker-dev
cd nextcloud-docker-dev
./bootstrap.sh
sudo sh -c "echo '127.0.0.1 nextcloud.local' >> /etc/hosts"
docker compose up nextcloud proxy
```

Ok, let's go to understand these commands line !

First, you download the project with the git command, then you move to the `nextcloud-docker-dev` folder.

The `bootstrap.sh` script check if all requirements are present and prepares your workspace.
You have the `./workspace` folder where there is the `server` folder, the Nextcloud's core and [other Nextcloud versions](docs/running-stable-versions.md) if you want (the stable21, stable22, stable23, and so on).

So, you if you want to contribute to the Nextcloud's core, you can work in this folder directly !

Then, you add `nextcloud.local` to your hosts file.

Finally, the `docker compose up nextcloud proxy` command line. This command line runs the nextcloud, proxy, redis and mailhog containers.

Once here, you can read the [First connection](#first-connection) section after seeing this result in your terminal :

```bash
nextcloud-nextcloud-1  |    The user "alice" was created successfully
nextcloud-nextcloud-1  |    The user "user6" was created successfully
nextcloud-nextcloud-1  |    The user "user1" was created successfully
nextcloud-nextcloud-1  |    The user "nextcloud" was created successfully
nextcloud-nextcloud-1  |    The user "user3" was created successfully
nextcloud-nextcloud-1  |    The user "user5" was created successfully
nextcloud-nextcloud-1  |    The user "jane" was created successfully
nextcloud-nextcloud-1  |    The user "john" was created successfully
nextcloud-nextcloud-1  |    The user "bob" was created successfully
nextcloud-nextcloud-1  |    The user "user4" was created successfully
nextcloud-nextcloud-1  |    The user "user2" was created successfully
```

This result means that all users are created and you can try to log in with the admin account or [other users](#which-user-accounts-can-i-use).

If you want to stop the services, you should use `Ctrl+C`. But, the containers are always running or presents.

Look at the status of your containers with `docker compose ps` :

```bahs
$ docker compose ps
NAME                         COMMAND                  SERVICE             STATUS              PORTS
nextcloud-database-mysql-1   "docker-entrypoint.s…"   database-mysql      running             0.0.0.0:8212->3306/tcp, :::8212->3306/tcp
nextcloud-mail-1             "MailHog"                mail                running             1025/tcp, 8025/tcp
nextcloud-nextcloud-1        "/usr/local/bin/boot…"   nextcloud           exited (0)          
nextcloud-proxy-1            "/app/docker-entrypo…"   proxy               exited (2)          
nextcloud-redis-1            "docker-entrypoint.s…"   redis               running             6379/tcp
```

To down your containers, use the `docker compose down -v` command :

```bash
foo@bar:~/Documents/codes/nextcloud-docker-dev$ docker compose down -v
[+] Running 16/5
 ⠿ Container nextcloud-nextcloud-1       Removed                                                                                                                                                                                                                             0.0s
 ⠿ Container nextcloud-proxy-1           Removed                                                                                                                                                                                                                             0.0s
 ⠿ Container nextcloud-mail-1            Removed                                                                                                                                                                                                                             0.6s
#...
foo@bar:~/Documents/codes/nextcloud-docker-dev$
 ```


Once you understand the mechanisms, you could run your containers in the background with the `-d` flag.

```bash
foo@bar:~/Documents/codes/nextcloud-docker-dev$  docker compose up -d proxy nextcloud
[+] Running 12/1
 ⠿ Network nextcloud_default               Created                                                                                                                                                                                                                           0.2s
 ⠿ Volume "nextcloud_postgres"             Created                                                                                                                                                                                                                           0.0s
 ⠿ Volume "nextcloud_mysql"                Created                                                                                                                                                                                                                           0.0s
 ⠿ Volume "nextcloud_smb"                  Created                                                                                                                                                                                                                           0.0s
 ⠿ Volume "nextcloud_clam"                 Created                                                                                                                                                                                                                           0.0s
 ⠿ Volume "nextcloud_document_data"        Created                                                                                                                                                                                                                           0.0s
#...
foo@bar:~/Documents/codes/nextcloud-docker-dev$
```

The difference with the `-d` flag is you can use your currently prompt after run the `docker compose` command.

## First connection

After running the `docker compose up nextcloud proxy` command, you have to wait a few minutes before trying to connect to your development instance.

In fact, you will see that the `nextcloud` and `proxy` containers initialize your Nextcloud, create  user accounts, and so on. Step by step.

Then, once these steps are completed, you can connect to your development instance. You must enter `http://nextcloud.local` in your address bar!

In fact, with the `proxy` container you don't need to specify the port number and you can't use `http://localhost` or `http://127.0.0.1`. Just, you have to use this address : `http://nextcloud.local`.


### Which user accounts can I use ?

Here is a list of user accounts you can use :

| uid | password |
|:---:|:---:|
| admin | admin |
| user1 | user1 |
| user2 | user2 |
| user3 | user3 |
| user4 | user4 |
| user5 | user5 |
| user6 | user6 |
| nextcloud | nextcloud |
| alice | alice |
| bob | bob |
| jane | jane |
| john | john |

## Where can I add my app for development ?

Once you have ran the Nextcloud's server with `docker compose`. You can clone your app in this folder : `./workspace/server/apps-extra/`.

Of course, you should adapt to the nextcloud release you are using (server, stable23, stable24, and so on.).

If you have not yet generated an app, you can do so from this web page : [https://apps.nextcloud.com/developer/apps/generate](https://apps.nextcloud.com/developer/apps/generate).


## Going further

If you want to go further, you can add new features or customize your development environment by following this documentation : [Configure my environment](docs/manual-setup.md#copy-environment-variables).

If you use **XDEBUG** to debug your PHP code. Please, read the [Set Up Xdebug](docs/setup-xdebug.md) documentation.

If you want to set up the Nextcloud's core, please, read the [Manual setup](docs/manual-setup.md) documentation.

If you aren't comfortable with Docker or other tools from the various containers (ldap, mysql, and so on.). You can read the [Useful commands](docs/useful-commands.md) file with some tips.

If you encounter any problems, please, look at this documentation : [Troubleshooting](docs/troubleshooting.md).

### Different feature you can use

These are features where you can use :

- ☁ Nextcloud
- 🔒 [Nginx proxy with SSL termination](docs/containers/ssl.md)
- 💾 [MySQL](docs/containers/mysql.md)
- 💡 Redis
- 👥 [LDAP with example user data](docs/containers/ldap.md)
- ✉ [Mailhog](docs/containers/mail.md)
- 🚀 [Blackfire](docs/containers/blackfire.md)
- 📄 [Collabora](docs/containers/collabora.md)
- 📄 [Only Office](docs/containers/onlyoffice.md)
- 👥 [SAML](docs/containers/saml.md)
- 🔍 [Full Text Search](docs/containers/fulltextsearch.md)
- 🪣 [Object Storage](docs/containers/objectstorage.md)
- 💉 [Antivirus](docs/containers/antivirus.md)
- 🔑 [Keycloak](docs/containers/keycloak.md)
- [Global Scale](docs/containers/globalscale.md)
- [Imaginary](docs/containers/imaginary.md)
