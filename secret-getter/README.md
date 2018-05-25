# [secret-getter](https://github.com/hms-dbmi/secret-getter)

## Build secret-getter Docker image

```bash
# build the executable-only Docker image
# this is a Docker image with *only* the secret-getter executable

# e.g. docker build -t dbmi/secret-getter:0.9-alpha \
#   --build-arg version=0.9-alpha \
#   --target=executable ./

$ docker build -t dbmi/secret-getter:<github tag or branch> \
    --build-arg version=<github tag or branch> \
    --target=executable ./

# build the runtime Docker image
# this adds the secret-getter executable to a base image and alters the entrypoint

# e.g. docker build -t dbmi/i2b2transmart:release-18.1-sg.0.9-alpha \
#   --build-arg version=0.9-alpha \
#   --build-arg base_image=dbmi/i2b2transmart \
#   --build-arg image_tag=release-18.1 \
#   --target=runtime ./

$ docker build -t <base_image>:<image_tag> \
    --build-arg version=<github tag or branch> \
    --build-arg base_image=<base_image> \
    --build-arg image_tag=<image_tag> \
    --target=runtime ./
```

## Use secret-getter with Vault

To read secrets, replace the command of the service with the secret-getter subcommands (vault, file) and its parameters, followed by `--` and the process' entrypoint and command options. Secret-getter will retrieve secrets and execute the entrypoint after, e.g.

### example

```bash
$ docker run dbmi/i2b2transmart:release-18.1-sg.0.9-alpha \
    vault -addr=https://localhost -path=/path/to/secrets \
    -token=<vault_token> -files=/files/for/string/regex \
    -prefix=\$$\{(?:System\.getenv\(\")? \
    -suffix=(?:\"\))?\} \
    -- ./bin/catalina.sh run
```

## Use secret-getter with Docker Secrets

secret-getter can retrieve `key=value` pairs in a file.

### example

`transmart_secrets.txt`

    DB_HOST=locahost
    DB_USER=biomart_user
    DB_PASSWORD="password"

```bash
# create a secret
$ docker secret create secret_file transmart_secrets.txt

# run container with secrets and secret-getter
$ docker run dbmi/i2b2transmart:release-18.1-sg.0.9-alpha \
    file --path=/run/secrets/secret_file \
    -files=/root/.grails/transmartConfig/DataSource.groovy
    -prefix=\$$\{(?:System\.getenv\(\")? \
    -suffix=(?:\"\))?\} \
    -- ./bin/catalina.sh run
```
