# Collabora

- Make sure to have the collabora hostname setup in your /etc/hosts file: `127.0.0.1 collabora.local`
- Automatically enable for one of your containers (e.g. the main nextcloud one):
	- Run `./scripts/enable-collabora nextcloud`
- Manual setup
	- Start the Collabora Online server in addition to your other containers `docker compose up -d collabora`
	- Make sure you have the richdocuments app cloned to your apps-extra directory and built the frontend code of the app with `npm ci && npm run build`
	- Enable the app and configure `collabora.local` in the Collabora settings inside of Nextcloud
