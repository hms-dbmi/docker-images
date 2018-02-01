# secret-getter

## code

<https://github.com/hms-dbmi/vault-getter>

## build image

Build the secret-getter executable

```
$ cd build/
$ docker build -t dbmi/secret-getter:latest ./
```

## add secret-getter to image

The following build command will add the secret-getter executable to your image

```
$ docker build -t dbmi/<image>:<version> \
--build-arg SERVICE=<image> --build-arg VERSION=version ./
$ # e.g.
$ docker build -t dbmi/i2b2transmart:1.0-GA \
--build-arg SERVICE=i2b2transmart --build-arg VERSION=1.0-GA ./
```

## use secret-getter

To read secrets, replace the entrypoint of the service with the secret-getter command followed by "--" followed by the existing entrypoint. secret-getter will retrieve secrets then execute the entrypoint after, e.g.

```
$ docker run --entrypoint=sh -c "secret-getter vault \
 -addr=https://localhost --path=/path/to/secrets \
 -token=<vault_token> --files=/files/for/string/regex \
 -prefix=\\{ --suffix=\\} \
 -- /docker-entrypoint" dbmi/<image> env
```
