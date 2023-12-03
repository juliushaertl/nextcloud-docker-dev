# Overview

## Nextcloud containers

There are multiple containers that can be started for Nextcloud. The main `nextcloud` container is targetting the main workspace directly (usually for running the master/main branch of Nextcloud server and apps) of the latest development version. In addition there are stable containers for running the stable major version branches in parallel.

Additional services like databases, redis cache, minio object storage and others are provided as separate containers and are shared between the different Nextcloud containers. They still isolate data of the individual Nextcloud containers from each other.

For any HTTP services a nginx proxy container is used to route requests to the correct container. This proxy is automatically started.

## Default users

The following user accounts are available by default:

- `admin` / `admin`
- `alice` / `alice`
- `bob` / `bob`
- `user1` / `user1`
- `user2` / `user2`
- `user3` / `user3`
- `user4` / `user4`