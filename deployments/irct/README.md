# PIC-SURE

## Versioning

Latest available Docker image versions:

- dbmi/nginx:irct.1.4.2
- dbmi/irct: 1.4.2
- dbmi/irct-init: 1.4.2
- mysql: latest

# How To Deploy

## Quick-Start sample

[PIC-SURE with i2b2.org Resource](quick-start/)

## Available Stacks

- _localdb.yml_ deploys a local MySQL database container with a corresponding named volume for data persistence

- _dev.yml_ deploys the PIC-SURE stack with debug ports open for enable remote debugging

- _prod.yml_ deploys the production PIC-SURE stack

## Populate .env File

```
# versions
nginx_version=irct.1.4.2
irct_version=1.4.2
irct_init_version=1.4.2
db_version=latest

## database host (required by container_name yaml tag)
# this sets a DNS entry for the container
IRCTMYSQLADDRESS=

## container environment variables file
# loads these values into the container
ENV_FILE=sample_project.env
```

### For Local Database Purposes (localdb.yml)

If you plan to use localdb.yml for your database, instead of a remote database, add the following to your .env file. Set the port to an open available port on your docker host, e.g. 3306

```
# local port (port must be available on docker host, check for conflicts -Andre)
DOCKER_IRCT_DB_PORT=
```

### For Development Purposes Only

If you plan to use dev.yml and deploy a development stack, add the following to the .env file. Set the value to the path to your localhost's directory containing the IRCT-CL.war file, e.g. /home/user/irct/IRCT-CL/target

```
## local volumes
LOCAL_IRCT=
```

## Project Configuration

### Create Project Env File

Either use the existing sample_project.env or create your own project environment variable file. Set values for keys with empty values.

If you use your own project env file, update your .env file, and set the value for key "ENV_FILE" to the name of your project environment file.

```
APPLICATION_NAME=

# pic-sure-init
# deprecated
IRCT_RESOURCE_NAME=

# pic-sure
# Note: the value here *must* equal the value in the .env file
# To-do: resolve requiring db host in 2 places - Andre
IRCTMYSQLADDRESS=
IRCT_DB_PORT=3306
IRCT_DB_CONNECTION_USER=root

# Note: IRCTMYSQLPASS *must* equal MYSQL_ROOT_PASSWORD
# former required by irct service,
# latter required by db service (localdb.yml only) -Andre
IRCTMYSQLPASS=
MYSQL_ROOT_PASSWORD=

IRCT_USER_FIELD=email
AUTH0_DOMAIN=avillachlab.auth0.com
AUTH0_CLIENT_ID=
AUTH0_CLIENT_SECRET=
EXTERNAL_URL=

# pic-sure s3 support
S3_BUCKET_NAME=
```

## Startup Database

### a. local database

```
$ cd deployments/irct
$ docker-compose -f localdb.yml up -d db
```

### b. remote database

Make sure your docker host has access to your database host and port. Set IRCTMYSQLADDRESS in your project env file to the database URL. Updating the value in .env is not required since you are _not_ using the database as a container (local db container)

## Initialize Database

Either prod.yml or dev.yml works to initialize database.

```
$ cd deployments/irct

# see available resources to install
$ docker-compose -f prod.yml run --rm irct-init

# e.g., to install i2b2.org resource, e.g.
$ docker-compose -f prod.yml run --rm irct-init -d irct -r i2b2

# e.g., to install i2b2transmart resource
$ docker-compose -f prod.yml run --rm irct-init -d irct -r i2b2transmart

# restart irct
$ docker-compose -f prod.yml restart irct
```

## Generate JWT token

Generate a JWT token with the client secret in your project's environment file with <https://github.com/hms-dbmi/jwt-creator.git>

## Test PIC-SURE Access

Show logs:

`$ docker-compose -f prod.yml logs -f irct`

Test query:

```
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Toke>" \
-X GET https://<docker host>/rest/v1/systemService/about
```

## Shutdown PIC-SURE

Any docker-compose yaml will shutdown the services in their stack. If you would like to remove _all_ services, add option --remove-orphans

```
$ cd deployments/irct

# e.g., removes services in prod.yml
$ docker-compose -f prod.yml down

# e.g., removes all services sharing same project name, include database found in localdb.yml and remotedb.yml
$ docker-compose -f prod.yml --remove-orphans
```
