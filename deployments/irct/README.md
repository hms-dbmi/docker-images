# PIC-SURE

## Versioning

### populate .env file

```
# versions
nginx_version=i2b2tm.1.0-GA
irct_version=1.4.2
irct_init_version=1.2.4

#### container environment variables ###
ENV_FILE=sample_project.env
```

## Project configuration

### create project env file

```
# irct
IRCT_RESOURCE_NAME=

IRCTMYSQLADDRESS=
IRCT_DB_PORT=3306
IRCT_DB_CONNECTION_USER=
IRCTMYSQLPASS=

AUTH0_DOMAIN=avillachlab.auth0.com
AUTH0_CLIENT_ID=
AUTH0_CLIENT_SECRET=
EXTERNAL_URL=

# irct s3 support
S3_BUCKET_NAME=

# irct db
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=irct
```

## Initialize database

```
$ cd deployments/irct
$ docker-compose -f localdb.yml up -d db
$ docker-compose -f localdb.yml up -d irct-init
$ # irct-init will fail & retry running scripts until irct creates the initial database and tables
$ # check progress
$ docker-compose -f localdb.yml logs -f irct-init
$ # restart irct
$ docker-compose -f localdb.yml restart irct
$ # TODO: docker commit mysql_database_irct:1.2.4 irct_db_1
```

## Deploy

```
$ cd deployments/irct
$ docker-compose -f localdb.yml up -d irct
```
