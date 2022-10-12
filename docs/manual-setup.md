# Manual setup

## Nextcloud Code

The Nextcloud code base needs to be available including the `3rdparty` submodule. To clone it from github run:

```bash
git clone https://github.com/nextcloud/server.git
cd server
git submodule update --init
pwd
```

The last command prints the path to the Nextcloud server directory.
Use it for setting the `REPO_PATH_SERVER` in the next step.