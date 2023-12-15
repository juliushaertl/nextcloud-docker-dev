# Build containers

This is usually only required if you want to test changes to the containers or if you want to build the containers yourself instead of using the prebuilt images.

You can build the containers manually for testing local changes by calling make with the Dockerfile as the target:

```bash
make docker/php82/Dockerfile
make docker/Dockerfile.php81
make docker/Dockerfile.php80
```

Afterward you can recreate the container with `docker compose up -d --force-recreate nextcloud` to run the new image or use `docker compose down -v` before to also reinstall Nextcloud.
