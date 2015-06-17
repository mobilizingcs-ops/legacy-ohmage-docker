# docker-ohmage

[ohmage](https://github.com/ohmage/server) is a participatory sensing platform.
This is a [docker](https://www.docker.io) image that eases setup of the server and/or platform.

## Usage

The docker containers built from this repository can be found at the docker hub: [base](https://registry.hub.docker.com/u/ohmage/base/) and [platform](https://registry.hub.docker.com/u/ohmage/platform/).

### base

The base container contains **only** the ohmage server project (with tomcat7 and mysql. see below for mysql specific notes). ohmage is served by the container from `8080` at the `/app` endpoint (the hardcoded endpoint is required for backwards compatability with many ohmage frontends). You can pass environment variables for some specific uses (in particular, to link a mysql container). 

If you'd just like to start to get a feel for ohmage, and don't care about data or database persistence, feel free to start with this command:

```bash
docker run -d -p 8080:8080 ohmage/base
```

If you'd like to link to a mysql container and keep data beyond the life of this container (let's assume the container's name is `mysql`), you can start like this:

```bash
docker run -d 
  -p 8080:8080 \
  --link mysql:mysql \
  -e DB_NAME=ohmage \
  -e DB_USER=ohmage \ 
  -e DB_PASS=ohmage \
  -v /some/host/directory:/var/lib/ohmage \
  ohmage/base
```

Note that in both cases port `8080` will be used on the docker host to support this container. Additionally, you'll likely want to pass a few environment variables for your case.

#### Environment Variables

  * `DB_HOST`: defaults to `localhost` unless mysql container is linked, in which case is set to `$MYSQL_PORT_3306_TCP_ADDR`
  * `DB_PORT`: defaults to `3306` unless mysql container is linked, in which case is set to `$MYSQL_PORT_3306_TCP_PORT`
  * `DB_NAME`: defaults to `ohmage`
  * `DB_USER`: defaults to `ohmage`
  * `DB_PASS`: defaults to `ohmage`
  * `FQDN`: defaults to `$HOSTNAME` (note this is used only important for ohmage when sending sign up links in email.)

### platform

This container contains a full ohmage platform, including commonly used web frontends. While it may not fit every usage (please see the `base` container above) this container is far more likely the container you'll want to use if launching a project on ohmage. The basic run use cases exist as above, with a single notable exception that this image exposes port `80` (nginx handles serving static data and reverse proxying to ohmage). Because of this, if you have to serve from a different point, you may need another reverse proxy to handle/prevent the squashing of port numbers in some redirect requests! Run with the command below and visit `/` to get started!

```bash
docker run -d -p 80:80 ohmage/platform
```

### profiler

This container is identical to the platform container, but includes the necessary configuration to connect the ohmage service running in the container to a java profiling tool! This will be formalized and actually deployed soon...but you're on your own for now. 

## Copyright
Copyright (c) 2015 UC Regents
See [LICENSE][] for details.

[license]: LICENSE