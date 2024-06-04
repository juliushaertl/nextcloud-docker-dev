# Update

## Updating the development environment

- `git pull` to get the latest changes
- Update the container images through either
  - `make pull-installed` to pull the latest versions of all images that are already downloaded
  - `make pull-all` to pull the latest versions of all images
- After pulling make sure to either recreate the containers manually or recreate the full development environment through `docker compose down -v` and `docker compose up -d nextcloud` for the containers in use.

## Updating the Nextcloud server

As Nextcloud containers are bound to a server major version and the code is updated through manual git pull.

It is recommended to stay up to date with the latest development version of the Nextcloud server:

```bash
cd workspace/server
git pull
git submodule update
```

For other apps checked out you might want to run a separate `git pull` in the respective directories.

If nextcloud requires migration steps it will ask you to run an upgrade which can be done with the following command:

```bash
docker compose exec nextcloud occ upgrade
```

### Major version bump

In case Nextcloud server bumps the major version, you will need to pull all repositories again to the latest state to get the compatibility changes.

You might want to take the opportunity to then set up the previous version as a new stable version setup. See [stable versions](stable-versions.md) for more information.
