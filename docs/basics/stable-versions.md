# Stable Nextcloud versions

As described in the [overview](overview.md) there are multiple Nextcloud containers available. The main `nextcloud` container is targetting the main workspace directly (usually for running the master/main branch of Nextcloud server and apps) of the latest development version. In addition there are stable containers for running the stable major version branches in parallel.

## Prepare your git checkouts for running a stable version

In order to run a stable version you need to have the corresponding git checkouts available. Using [git worktree](https://blog.juliushaertl.de/index.php/2018/01/24/how-to-checkout-multiple-git-branches-at-the-same-time/) makes it easy to have different branches checked out in parallel in separate directories and is the recommended way to work with stable branches in parallel.

Assuimg you have already cloned the repository into `~/nextcloud-docker-dev/workspace/server` you can run the following commands to create a new worktree for the stable28 branch:

```bash
# create a new worktree for the stable28 branch
cd ~/nextcloud-docker-dev/workspace/server
git worktree add ../stable28 stable28
cd ~/nextcloud-docker-dev/workspace/stable28
# make sure submodules are installed in the stable server root directory
git submodule update --init
```

### Add worktree for additional apps

This will be required for every app that you need on the stable branches, so run this for viewer but also for any other app you need.

```bash
cd ~/nextcloud-docker-dev/workspace/server/apps/viewer
git worktree add ../../../stable28/apps/viewer stable28
```

## Start the stable28 container

```bash
docker-compose up -d stable28
```

## Apps without stable branches

Some apps do not have stable branches or cover multiple Nextcloud version. You can use the `ADDITIONAL_APPS_PATH` variable in your `.env` file to add add a cloned app to all Nextcloud containers. By default this is set to `./data/apps-extra`
