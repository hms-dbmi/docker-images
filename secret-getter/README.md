# secret-getter

## Build secret-getter

Build the secret-getter executable

```
# build the executable-only Docker image
# e.g. docker build --build-arg version=0.9-alpha -t dbmi/secret-getter:0.9-alpha --target=executable ./
$ docker build --build-arg version=<github tag or branch> -t dbmi/secret-getter:<github tag or branch> --target=executable ./

# build the runtime Docker image
# e.g. docker build --build-arg version=0.9-alpha -t dbmi/secret-getter:0.9-alpha-runtime --target=runtime ./
$ docker build --build-arg version=<github tag or branch> -t dbmi/secret-getter:<github tag or branch>-runtime --target=runtime ./
```

## Add secret-getter to your Dockerfile

Append the following lines into your Dockerfile, then build your Dockerfile. This will update your Docker image by adding the secret_getter executable into /usr/bin, and change your ENTRYPOINT to run /usr/bin/secret_getter, and CMD to "--help"

```
FROM dbmi/secret-getter:<release> AS executable
FROM dbmi/secret-getter:<release>-runtime
```

## Use secret-getter

To read secrets, replace the command of the service with the secret-getter subcommands (vault, file) and its parameters, followed by `--` with the process entrypoint and command options. secret-getter will retrieve secrets and execute the entrypoint after, e.g.

```
$ docker run --entrypoint=sh dbmi/<image> \
 vault --addr=https://localhost --path=/path/to/secrets \
 --token=<vault_token> --files=/files/for/string/regex \
 -prefix=\\{ --suffix=\\} \
 -- /docker-entrypoint cmd_option1
```
