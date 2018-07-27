# PIC-SURE

## Versioning

Latest available Docker image versions:

-   dbmi/nginx:alpine-tmpl.1.0
-   dbmi/irct: 1.4.2.tokenIntro
-   dbmi/irct-db: mysql.5.7.22-irct.1.4.2-i2b2-wildfly
-   dbmi/i2b2-db: oracle.12.2.0.1-ee-i2b2.1.7.09
-   dbmi/i2b2-wildfly: 1.7.09c
-   dbmi/picsure2: 0.0.0.irct_included
-   dbmi/picsure-db: mysql.5.7.22-irct-and-user

# How To Deploy

## Env Files

-   _Required_: `*_version=`, `IRCTMYSQLADDRESS=`, `ENV_FILE=`, `IRCT1_ENV_FILE=`, `IRCT2_ENV_FILE`.

-   Optional: `STACK_ENV=`, `STACK_NAME`, `WHITELIST_PATH`.

```bash
## versions
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
PICSURE2_MYSQLADDRESS=picsuredb
COMPOSE_HTTP_TIMEOUT=200
ENV_FILE=grin.env
IRCT_1_ENV_FILE=irct1.env
IRCT_2_ENV_FILE=irct2.env
## To use a whitelist, set this variable to the directory where your whitelist.json is located
WHITELIST_PATH=
```

Existing `grin.env` file should not need to be modified.
For `irct1.env` and `irct2.env`, only which `WHITELIST_PATH` variable is used needs to be modified

## Deploy

```bash
 $ cd deployments/grin
 $ docker-compose up -d
```

## Generate JWT token

A test user with email foo@bar.com is already installed in the system.  Generate a JWT token with the `PIC_SURE_CLIENT_SECRET` in the environment file with [JWT Creator](https://github.com/hms-dbmi/jwt-creator.git)

## Test PIC-SURE Access

Show logs:

`$ docker-compose logs -f irct`

See available resources.  IRCT should already be installed.

Run
```bash
$ docker-machine ip
```
to find out the ip of your docker host.

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/picsure2/pic-sure-api-2/PICSURE/info/resources
```

You can access the swagger.json for information about what endpoints are available:
```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/picsure2/pic-sure-api-2/PICSURE/swagger.json
```

Additional users can be added:
```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X POST --data '{"userId" : "<userId>", "subject" : "<userId>", "roles" : "ROLE_INTROSPECTION_USER" }' \
https://<docker host>/picsure2/pic-sure-api-2/PICSURE/user
```


## Shutdown PIC-SURE

Any docker-compose yaml will shutdown the services in their stack. If you would like to remove _all_ services, add option `--remove-orphans`
```bash
    $ docker-compose down
```
