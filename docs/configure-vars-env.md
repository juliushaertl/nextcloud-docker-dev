# Configure my environment

## Copy environment variables

A `.env` file should be created in the repository root, to keep configuration default on the dev setup:

```
cp example.env .env
```

Replace `REPO_PATH_SERVER` with the path from above.

## Setting the PHP version to be used

The Nextcloud instance is setup to run with PHP 7.2 by default.
If you wish to use a different version of PHP, set the `PHP_VERSION` `.env` variable.

The variable supports the following values:

1. PHP 7.1: `71`
1. PHP 7.2: `72`
1. PHP 7.3: `73`
1. PHP 7.4: `74`
1. PHP 8.0: `80`
