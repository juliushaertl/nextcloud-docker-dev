# nextcloud-dev-docker-compose

Hi beginner developer ! 👋

This project allows you to get started a nextcloud server and develop your first app !

This project is very **modular** where you can add [features](#different-feature-you-can-use).
So, you can use this project for your development environment only.

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

If you want to go further, you can add new features or customize your development environment by following this documentation : [Configure my environment](docs/configure-vars-env.md).

If you use **XDEBUG** to debug your PHP code. Please, read the [Set Up Xdebug](docs/setup-xdebug.md) documentation.

If you want to set up the Nextcloud's core, please, read the [Manual setup](docs/manual-setup.md) documentation.

If you encounter any problems, please, look at this documentation : [Troubleshooting](docs/troubleshooting.md).

### Different feature you can use

These are features where you can use :

- ☁ Nextcloud
- 🔒 Nginx proxy with SSL termination
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
