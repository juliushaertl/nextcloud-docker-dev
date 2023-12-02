# Getting started

The easiest way to get the setup running the ```master``` branch is by running the ```bootstrap.sh``` script:
```
git clone https://github.com/juliushaertl/nextcloud-docker-dev
cd nextcloud-docker-dev
./bootstrap.sh
sudo sh -c "echo '127.0.0.1 nextcloud.local' >> /etc/hosts"
docker-compose up nextcloud proxy
```

This will clone the server repository into the ```workspace/server``` directory and start the containers. The server will be available at http://nextcloud.local.

Note that for performance reasons the server repository might have been cloned with --depth=1 by default. To get the full history it is highly recommended to run:

	cd workspace/server
	git fetch --unshallow
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch origin

This may take some time depending on your internet connection speed.
