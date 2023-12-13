# Update

## Updating the development environment

- `git pull` to get the latest changes
- `make pull-installed` to pull the latest versions of all images that are already downloaded
- `make pull-all` to pull the latest versions of all images
- After pulling make sure to either recreate the containers manually or recreate the full development environment through `docker compose down -v` and `docker compose up -d proxy nextcloud ...` for the containers in use.

## Updating the Nextcloud server

As Nextcloud containers are bound to a server major version and the code is updated through manual git pull, you only need to call occ update on demand

```bash
docker-compose exec nextcloud occ upgrade
```

### Major version bump

In case Nextcloud server bumps the major version, you will need to pull all repositories again to the latest state to get the compatibility changes.

You might want to take the opportunity to then set up the previous version as a new stable version setup. See [stable versions](stable-versions.md) for more information.
