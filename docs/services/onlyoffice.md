# ONLYOFFICE

ONLYOFFICE is a self-hosted office suite that can be used with Nextcloud.

## Automatic setup

A script is available to automatically setup ONLYOFFICE for you combined with an already running Nextcloud container.

It requires to have the onlyoffice integration app cloned into your apps directory.

```bash
./scripts/enable-onlyoffice <container-name>
```

## Manual steps

- Make sure to have the ONLYOFFICE hostname setup in your `/etc/hosts` file: `127.0.0.1 onlyoffice.local`
- Start the ONLYOFFICE server in addition to your other containers `docker-compose up -d onlyoffice`
- Clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud into your apps directory
- Enable the app and configure `onlyoffice.local` in the ONLYOFFICE settings inside of Nextcloud