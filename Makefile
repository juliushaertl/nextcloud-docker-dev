SHELL := /bin/bash

.PHONY: images
.ONESHELL:
images:
	for file in $$(find docker/ -maxdepth 1 -type f -iname 'Dockerfile.*'); do \
		NAME=$$(echo $$file | sed 's/^.*\.//'); echo "=> Building image $$NAME"; \
		(cd docker && docker build -t ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest -f Dockerfile.$$NAME .)
	done

.PHONY: pull
.ONESHELL:
pull:
	for file in $$(find docker/ -maxdepth 1 -type f -iname 'Dockerfile.*'); do \
		NAME=$$(echo $$file | sed 's/^.*\.//'); echo "=> Pulling image $$NAME"; docker pull "ghcr.io/juliushaertl/nextcloud-dev-$${NAME}"; \
	done

check: dockerfilelint shellcheck

.ONESHELL:
dockerfilelint:
	for file in $$(find docker/ -type f -iname 'Dockerfile.*' -maxdepth 1); do dockerfilelint $$file; done;

.ONESHELL:
shellcheck:
	for file in $$(find . -type f -iname '*.sh' -not -path './wip/*'); do shellcheck --format=gcc $$file; done;

.ONESHELL:
template-apply:
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.1/' > docker/Dockerfile.php71
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.2/' > docker/Dockerfile.php72
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.3/' > docker/Dockerfile.php73
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:7.4/' > docker/Dockerfile.php74
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:8.0/' > docker/Dockerfile.php80
	cat docker/Dockerfile.php.template | sed 's/php:8.1/php:8.1/' > docker/Dockerfile.php81
