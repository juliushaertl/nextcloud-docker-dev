# nextcloud-dev

Docker image for [NextCloud][] for development

This image pulls the NextCloud source from the host filesystem while maintaining a seperate config and data directory which makes it easy to test your local code in a clean NextCloud instance.

The build instructions are tracked on [GitHub][this.project_github_url].
Automated builds are hosted on [Docker Hub][this.project_docker_hub_url].

This image is based on https://github.com/icewind1991/nextcloud-dev and adapted for use with https://github.com/juliushaertl/nextcloud-docker-dev

## License

This project is distributed under [GNU Affero General Public License, Version 3][AGPLv3].
[NextCloud]: https://nextcloud.com/
[AGPLv3]: https://github.com/nextcloud/server/blob/master/COPYING-AGPL
[this.project_docker_hub_url]: https://registry.hub.docker.com/u/icewind1991/nextcloud-dev/
[this.project_github_url]: https://github.com/icewind1991/nextcloud-dev
