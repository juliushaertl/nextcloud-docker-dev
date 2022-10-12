# Running stable versions

The docker compose file provides individual containers for stable Nextcloud releases. In order to run those you will need a checkout of the stable version server branch to your workspace directory. Using [git worktree](https://blog.juliushaertl.de/index.php/2018/01/24/how-to-checkout-multiple-git-branches-at-the-same-time/) makes it easy to have different branches checked out in parallel in separate directories.

Note that for performance reasons the server repository might have been cloned with --depth=1 by default. To get the full history it is highly recommended to run:

```bash
cd workspace/server
git fetch --unshallow
```

 This may take some time depending on your internet connection speed.

```bash
cd workspace/server
git worktree add ../stable23 stable23
cd ../stable23
git submodule update --init
```

After adding the worktree you can start the stable container using `docker compose up -d stable23`. You can then add stable23.local to your `/etc/hosts` file to access it.

Git worktrees can also be used to have a checkout of an apps stable brach within the server stable directory.

```bash
cd workspace/server/apps-extra/text
git worktree add ../../../stable23/apps-extra/text stable23
```
