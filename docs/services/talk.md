# Talk HPB

- Make sure to have the signaling hostname setup in your `/etc/hosts` file: `127.0.0.1 talk-signaling.local`
- Automatically enable for one of your containers (e.g. the main `nextcloud` one):
  - Run `./scripts/enable-talk-hpb.sh nextcloud`
- Manual setup
  - Start the talk signaling server and janus in addition to your other containers `docker-compose up -d talk-signaling talk-janus`
  - Go to the admin settings of talk and add the signaling server (`http://talk-signaling.local` with shared secret `1234`)
