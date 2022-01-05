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
		NAME=$$(echo $$file | sed 's/^.*\.//'); echo "=> Pulling image $$NAME"; docker pull "ghcr.io/juliushaertl/nextcloud-dev-$${NAME}";
	done

check: dockerfilelint shellcheck

.ONESHELL:
dockerfilelint:
	for file in $$(find docker/ -type f -iname 'Dockerfile.*' -maxdepth 1); do dockerfilelint $$file; done;

.ONESHELL:
shellcheck:
	for file in $$(find . -type f -iname '*.sh' -not -path './wip/*'); do shellcheck --format=gcc $$file; done;
