# PIC-SURE

## Versioning

Latest available Docker image versions:

-   dbmi/nginx:alpine-tmpl.1.0
-   dbmi/irct: 1.4.2.tokenIntro
-   dbmi/irct-db: mysql.5.7.22-irct.1.4.2-i2b2-wildfly
-   dbmi/i2b2-db: oracle.12.2.0.1-ee-i2b2.1.7.09
-   dbmi/i2b2-wildfly: 1.7.09c
-   dbmi/picsure2: 0.0.0.irct_included
-   dbmi/picsure-db: *****mysql.5.7.22-irct-and-user******

# How To Deploy

## Populate .env File

-   _Required_: `*_version=`, `IRCTMYSQLADDRESS=`, `ENV_FILE=`, `IRCT1_ENV_FILE=`, `IRCT2_ENV_FILE`.

-   Optional: `STACK_ENV=`, `STACK_NAME`, `WHITELIST_PATH`, `LOCAL_PICSURE2`.

```bash
nginx_version=alpine-tmpl.1.0
irct_version=1.4.2.tokenIntro
irct_db_version=mysql.5.7.22-irct.1.4.2-i2b2-wildfly
oracle_db_version=oracle.12.2.0.1-ee-i2b2.1.7.09
picsure2_version=0.0.0.irct_included
i2b2_wildfly_version=1.7.09c
picsure_mysql_version=mysql.5.7.22-irct-and-user

## labeling
STACK_ENV=prod
STACK_NAME=grin_env
COMPOSE_PROJECT_NAME=grin_env

## container environment variables
# loads these values into the container
ENV_FILE=grin.env
IRCT_1_ENV_FILE=irct1.env
IRCT_2_ENV_FILE=irct2.env
PICSURE2_MYSQLADDRESS=picsuredb
COMPOSE_HTTP_TIMEOUT=200


## To use a whitelist, set this variable to the directory where your whitelist.json is located
WHITELIST_PATH=


## To develop with PICSURE 2.0, set this variable to the directory where your picsure repository is located
LOCAL_PICSURE2=
```

## Project Configuration

### Project Env Files

Existing `grin.env` file should not need to be modified.
For `irct1.env` and `irct2.env`, only which `WHITELIST_PATH` variable is used needs to be modified (see Development Section)

If you use your own project env file, update your `.env` file, and set the value for key `ENV_FILE=` to the name of your project environment file.

## Deploy

```bash
 $ cd deployments/grin
 $ docker-compose up -d
```

## Generate JWT token

Generate a JWT token with the `CLIENT_SECRET` in your project's environment file with [JWT Creator](https://github.com/hms-dbmi/jwt-creator.git)

## Test PIC-SURE Access

Show logs:

`$ docker-compose logs -f irct`

See available resources.  IRCT should already be installed.

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/pic-sure-api-2/PICSURE/info/resources
```
Using the uuid from the resource:

Test query:

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/pic-sure-api-2/PICSURE/query/{{resourceUUID}}

## Shutdown PIC-SURE

Any docker-compose yaml will shutdown the services in their stack. If you would like to remove _all_ services, add option `--remove-orphans`

    # e.g., removes services in prod.yml
    $ docker-compose down

    # e.g., removes all services sharing same project name, include database found in localdb.yml and remotedb.yml
    $ docker-compose --remove-orphans
