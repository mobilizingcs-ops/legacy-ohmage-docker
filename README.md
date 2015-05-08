# docker-ohmage

[ohmage](https://github.com/ohmage/server) is a participatory sensing platform.
This is a [docker](https://www.docker.io) image that eases setup of the server component (future work includes all-in-one containers).

## Usage

This docker image is available [here](https://registry.hub.docker.com/u/stevenolen/ohmage/),
so there's no setup required.
Using this image for the first time will start a download automatically.
Further runs will be immediate, as the image will be cached locally.

The recommended way to run this container looks like this:

```bash
$ docker run -d -p 8080:8080 -v stevenolen/ohmage
```

The above example exposes the ohmage server on 8080 with the default endpoint of `/app`. Feel free to take a look at the config/read api to ensure it is running:

```
http://localhost:8080/app/config/read
```

### Persistence, MySQL and ohmage data files.

Not much use for your data to be deleted when the container goes away, right? If you'd like to persist the ohmage data files (images, media, documents), pass `-v /localstorage/location:/var/lib/ohmage` when starting the docker container. 

You can also link a mysql container (in which case this container wont run mysql) by passing the options below. For example if your container is called `mysql`:

```bash
docker run -it --link mysql:db_hostname -e DB_HOST=db_hostname
```

## Copyright
Copyright (c) 2015 UC Regents
See [LICENSE][] for details.

[license]: LICENSE