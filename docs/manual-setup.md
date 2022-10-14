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

## Configure my environment

### Copy environment variables

For this section you don't need to run the `./bootstrap.sh` script.

Here, we learn how to customise our development environment !

First, a `.env` file should be created in the repository root, to keep configuration default on the dev setup:

```bash
cp example.env .env
```

Replace `REPO_PATH_SERVER` with your path using the `pwd` command from the project.

```bash
foo@bar:~/Documents/codes/nextcloud-docker-dev$ pwd
/home/foo/Documents/codes/nextcloud-docker-dev
```

And the new value is :

```bash
REPO_PATH_SERVER=/home/foo/Documents/codes/nextcloud-docker-dev/workspace/server
```

### Setting the PHP version to be used

The Nextcloud instance is setup to run with PHP 8.1 by default.
But, the program adapts the PHP default release to suit the Nextcloud stable release using. For example, the stable23 use PHP 7.3 and the stable24 use PHP 7.4.

If you wish to use a different version of PHP, set the `PHP_VERSION` `.env` variable.

The variable supports the following values:

1. PHP 7.1: `71`
1. PHP 7.2: `72`
1. PHP 7.3: `73`
1. PHP 7.4: `74`
1. PHP 8.0: `80`
