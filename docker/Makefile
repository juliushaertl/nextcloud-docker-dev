.PHONY: Dockerfile.*
Dockerfile.*:
	NAME=$$(echo $@ | sed 's/^.*\.//'); echo "=> Building image $$NAME"; \
	(docker build -t ghcr.io/juliushaertl/nextcloud-dev-$$NAME:latest -f Dockerfile.$$NAME .)
