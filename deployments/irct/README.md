# PIC-SURE

## Versioning

Latest available Docker image versions:

-   dbmi/nginx:irct.1.4.2
-   dbmi/irct: 1.4.2
-   dbmi/irct-init: 1.4.2
-   dbmi/irct-db: mysql.5.7.22-irct.1.4.2
-   mysql: 5.7.22

# How To Deploy

## Quick-Start sample

[PIC-SURE with i2b2.org Resource](quick-start/)

## Available Stacks

-   _builddb.yml_ deploys a local MySQL database to be configured and populated with available PIC-SURE resources

-   _localdb.yml_ deploys a local MySQL database container with a corresponding named volume for data persistence

-   _dev.yml_ deploys the PIC-SURE stack with all ports exposed, including debug ports

-   _prod.yml_ deploys the production PIC-SURE stack

-   (TODO) _secure.yml_ deploys the production PIC-SURE stack with secrets management and encrypted internal networks

## Populate .env File

-   _Required_: `*_version=`, `IRCTMYSQLADDRESS=`, `ENV_FILE=`.

-   Optional: `STACK_ENV=`, `STACK_NAME`

```bash
# versions
nginx_version=irct.1.4.2
irct_version=1.4.2
irct_init_version=1.4.2b
mysql_version=5.7.22
db_version=mysql.5.7.22-irct.1.4.2

## database host (required by container_name yaml tag)
# this sets a DNS entry for the container
IRCTMYSQLADDRESS=

## container environment variables file
# loads these values into the container
ENV_FILE=sample_project.env

## labeling
STACK_ENV=
STACK_NAME=
```

### For Local Database Purposes (localdb.yml)

If you plan to use `localdb.yml` for your database, instead of a remote database, add the following to your `.env` file. Set the port to an open available port on your docker host. By default, `localdb.yml` will expose 3306.

```bash
# local port (port must be available on docker host, check for conflicts -Andre)
DOCKER_IRCT_DB_PORT=
```

### For Development Purposes Only (dev.yml)

If you plan to use `dev.yml` and deploy a development stack, add the following to the `.env` file. Set the value to the path to your localhost's directory containing the _IRCT-CL.war_ file, e.g. /home/user/irct/IRCT-CL/target

```bash
### for development purposes only (dev.yml) ###

## local volumes
LOCAL_IRCT=
```

## Project Configuration

### Create Project Env File

Either use the existing `sample_project.env` or create your own project environment variable file. Set values for keys with empty values.

If you use your own project env file, update your `.env` file, and set the value for key `ENV_FILE=` to the name of your project environment file.

```bash
# nginx (server name)
APPLICATION_NAME=

# pic-sure
IRCTMYSQLADDRESS=
IRCT_DB_PORT=3306
IRCT_DB_CONNECTION_USER=root

# Note: IRCTMYSQLPASS *must* equal MYSQL_ROOT_PASSWORD
# former required by pic-sure service,
# latter required by localdb service only -Andre
IRCTMYSQLPASS=
MYSQL_ROOT_PASSWORD=

IRCT_USER_FIELD=email

# required for any JWT tokens generation,
CLIENT_ID=
CLIENT_SECRET=

### Resources ####

# i2b2/tranSMART 1.0-GA
AUTH0_DOMAIN=avillachlab.auth0.com
```

## Install Resources into PIC-SURE database, Create Snapshot

```bash
$ cd deployments/irct
$ docker-compose -f builddb.yml up -d

# wait for irct to populate the database
$ docker-compose -f builddb.yml logs -f irct
# HHH000228: Running hbm2ddl schema update
# ....
# HHH000262: Table not found: VisualizationType_Field
# HHH000262: Table not found: where_values
# HHH000262: Table not found: where_values
# Starting IRCT Application


# install data converters resource
$ docker-compose -f builddb.yml run --rm irct-init -r dataconverters


# install i2b2.org resource
$ docker-compose -f builddb.yml run --rm irct-inint -r i2b2.org


# install additional resources (optional)
$ docker-compose -f builddb.yml run --rm irct-init -r [availableResource]
# options:
# -e external URL       required: for i2b2transmart Resource
# -b bucket name        optional: for i2b2transmart Resource. add AWS S3 bucket
# -s true|false         optional: for i2b2-wildfly Resource. Simple install only
# -c true|false         optional: confirms Resource is installed

# Available resources:
# i2b2transmart-[name of resource]
# scidb
# i2b2.org
# dataconverters
# i2b2-wildfly-[name of resource]
# monitor
#
# ex: docker-compose -f builddb.yml run --rm irct-init -r i2b2-wildfly-demo -s true

# save state of the database
$ docker commit db dbmi/irct-db:mysql.5.7.22-irct.1.4.2-i2b2-org

$ docker-compose -f builddb.yml restart irct
```

Update the `db_version=` in .env to the saved database snapshot. There are sample databases available at [Docker Hub](https://hub.docker.com/r/dbmi/irct-db/)

## Startup Database

### a. local database

    $ cd deployments/irct
    $ docker-compose -f localdb.yml up -d db

### b. remote database

Make sure your docker host has access to your database host and port. Set `IRCTMYSQLADDRESS=` in your project env file to the database URL. Updating the value in .env is _not required_ since you are _not_ using the database as a container (local db container)

## Deploy

Once your database is up, use `dev.yml`, `prod.yml` to deploy the stack

```bash
 $ cd deployments/irct
 $ docker-compose -f dev.yml up -d irct
```

You may continue to add resources to the database by `docker-compose -f prod.yml run --rm irct-init`, but those resources will not be saved to the Docker image. You will need to follow steps in [Create Database Snapshot](#create-database-snapshot)

## Generate JWT token

Generate a JWT token with the `CLIENT_SECRET` in your project's environment file with [JWT Creator](https://github.com/hms-dbmi/jwt-creator.git)

## Test PIC-SURE Access

Show logs:

`$ docker-compose -f prod.yml logs -f irct`

Test query:

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/rest/v1/systemService/about
```

## Shutdown PIC-SURE

Any docker-compose yaml will shutdown the services in their stack. If you would like to remove _all_ services, add option `--remove-orphans`

    $ cd deployments/irct

    # e.g., removes services in prod.yml
    $ docker-compose -f prod.yml down

    # e.g., removes all services sharing same project name, include database found in localdb.yml and remotedb.yml
    $ docker-compose -f prod.yml --remove-orphans
