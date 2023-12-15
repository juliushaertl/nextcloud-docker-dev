# Nextcloud Office / Collabora Online

Nextcloud Office is a self-hosted and online office suite that can be used with Nextcloud based on Collabora Online.

## Automatic setup

A script is available to automatically setup Collabora Online for you combined with an already running Nextcloud container.

It requires to have the [richdocuments](https://github.com/nextcloud/richdocuments) app cloned into your apps directory.

```bash
./scripts/enable-collabora <container-name>
```

## Manual steps

- Make sure to have the Collabora hostname setup in your `/etc/hosts` file: `127.0.0.1 collabora.local`
- Clone, build and enable the [richdocuments](https://github.com/nextcloud/richdocuments) app
- Start the Collabora Online server in addition to your other containers `docker compose up -d collabora`
- Make sure you have the [richdocuments app](https://github.com/nextcloud/richdocuments) cloned to your `apps-extra` directory and built the frontend code of the app with `npm ci && npm run build`
- Enable the app and configure `collabora.local` in the Collabora settings inside of Nextcloud

## Using with HTTPS

To properly work with HTTPS, you need to add the following parameter to the Collabora container in the `.env`file:

```
COLLABORA_PARAMS="--o:ssl.termination=true"
```
