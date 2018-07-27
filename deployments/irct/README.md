# PIC-SURE

* * *

## Configuration

1.  Create a project env file. These are for non-secret environment configurations There is an example `sample_project.env`
2.  Create a secrets env file.  These are for secrets, including database passwords. There is an example `sample_secrets.env`
3.  Update `.env` with the desired service versions. By default `.env` is setup to deploy the `sample_project` stack

* * *

## Setup your Development/Production Environment

Use [../tools/switchenv.sh](https://github.com/hms-dbmi/docker-images/tools/switchenv.sh) to setup the environment.

-   overrides default service versions found in `.env`
-   setups ssh-tunneling to a remote database
-   setups secrets

```bash
Usage:
  switchenv.sh [ARGS]
  switchenv.sh -h|--help

Enviornment Arguments:
  -e, --environment ENV       [required] Project to deploy.
                              [prerequisite] Matching <ENV>.env, <ENV>.secret files in current directory.
  -t, --type transmart|irct   [required] Deployment types. Determines Database type.
  -r, --remote true|false     Enables ssh-tunneling for remote database use [default: false].
                              [prerequisite] ssh-agent.
                              [prerequisite] Matching ssh config option <ENV> in /.ssh/config.

Secrets Arguments:
  -s, --secrets vault|file|none   Secrets Vault to use [default: none]
  --options OPTIONS...            OPTIONS available for secret_getter
  --options help                  Usage for secret_getter

Service Versioning Arguments:
  --service SERVICE           Modify SERVICE to deploy.
  -v, --version VERSION       Set SERVICE VERSION to deploy. Overrides default VERSION in .env

Other Arguments:
  --dry-run true|false        Dry run deployment settings [default: false].
```

### Examples

```bash
# ####
# update service version
# ####
$ ../tools/switchenv.sh --service irct --version 1.4.2c

# service version
# i2b2transmart_version=release-18.1-beta-7

# ####
# setup environment for sample_project deployment with file secrets
# ####
$ ../tools/switchenv.sh --environment sample_project --type irct \
--secrets file --options "--path=/run/secrets/secret"

# Using sample_project.env
#
# Using sample_project.secret
#
# Setting up irct
#
# # Environment Variables
#
# COMPOSE_PROJECT_NAME=sample_project
# ENV_FILE=sample_project.env
# SECRET_FILE=sample_project.secret
# SSH_CONFIG_CONFIG=sample_project
# STACK_NAME=sample_project
#
# # database
# IRCT_DB_HOST=db
#
# # secrets
# SG_COMMAND=file
# SG_OPTIONS=--path=/run/secrets/secret
```

* * *

## Build IRCT Database

To build a IRCT MySQL Database with available resources, run `builddb.yml`.

-   **NOTE**: `builddb.yml` uses secrets as environment variables, however building the IRCT database occurs on a closed, encrypted network. The containers cannot communicate outside the network.
-   There are sample databases with resources available at [Docker Hub](https://hub.docker.com/r/dbmi/irct-db/).

Run the following commands to populate your database with available resources:

```bash
$ cd deployments/irct
$ docker-compose -f builddb.yml up -d

# wait for IRCT to populate the database
$ docker-compose -f builddb.yml logs -f irct
# HHH000228: Running hbm2ddl schema update
# ....
# HHH000262: Table not found: VisualizationType_Field
# HHH000262: Table not found: where_values
# HHH000262: Table not found: where_values
# Starting IRCT Application


# REQUIRED: install data converters resource
$ docker-compose -f builddb.yml run --rm irct-init -r dataconverters

# OPTIONAL: install local i2b2-wildfly resource
# This resource makes i2b2 requests through a local wildfly to your i2b2 database
# Use this resource along with addons/i2b2-wildfly.yml and addons/i2b2-db.yml
$ docker-compose -f builddb.yml run --rm irct-init -r i2b2-wildfly-default

# OPTIONAL: install i2b2.org PCI-SURE resource
# This resource makes i2b2 requests to i2b2.org through PIC-SURE
$ docker-compose -f builddb.yml run --rm irct-init -r i2b2-wildfly-i2b2-org --resource-url http://services.i2b2.org:9090/i2b2/services/

# OPTIONAL: install i2b2.org passthrough resource
# This resource makes i2b2 XML requests to i2b2.org
$ docker-compose -f builddb.yml run --rm irct-init -r i2b2.org

# OPTIONAL: install additional resources
$ docker-compose -f builddb.yml run --rm irct-init --help
# Usage:
#   ./install.sh [DATABASE ARGS] [RESOURCE] [options] [RESOURCE ARGS...]
#   ./install.sh -h|--help
#
# Database Args:
#   -h, --host HOST             database host [default: $IRCT_DB_HOST]
#   -u, --user USER             database user [default: $IRCT_DB_CONNECTION_USER]
#   -p, --password PASSWORD     database password [default: $IRCT_DB_PASSWORD]
#
# Resources:
#   -r, --resource TYPE         resource to install
#
# Available Resource TYPE:
#   i2b2transmart-NAME
#   i2b2-wildfly-NAME
#   scidb-NAME
#   i2b2.org
#   dataconverters
#   monitor
#   capitalization
#
# Options:
#   --delete  true|false        delete resource
#   --confirm true|false        confirm resource is installed [default: false]
#
# Resource Args:
#   i2b2transmart-NAME:
#   --resource-url URL          [required] i2b2transmart URL
#   --auth0-id CLIENT_ID        [required] Auth0 Client Id
#   --auth0-domain DOMAIN       [required] Auth0 Domain
#   --bucket NAME               AWS S3 bucket
#
#   i2b2-wildfly-NAME:
#   --simple true|false         count only install [default: false]
#   --resource-url URL          i2b2-wildfly URL [default: http://i2b2-wildfly:9090/i2b2/services/]
#   --resource-user USER        i2b2 user [default: demo]
#   --resource-pass PASSWORD    i2b2 password [default: demouser]
#   --resource-domain DOMAIN    i2b2 domain [default: i2b2demo]
#
#   scidb-NAME:
#   --resource-url URL          [required] SciDB host
#   --resource-user USER        [required] SciDB user
#   --resource-pass PASSWORD    [required] SciDB password
#   --afl-enabled true|false    use SciDB's Array Functional Language [default: false]
#
# Unavailable Resources:
#   hail
#   gnome
#   exac
#   umls

# save state of the database
$ docker ps
# CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
# 600d66204ea1        dbmi/irct:1.4.2c      "/opt/jboss/wildfl..."   5 minutes ago       Up 5 minutes                            sample_project_irct_1
# baf3fbcaad27        mysql:5.7.22        "docker-entrypoint..."   5 minutes ago       Up 5 minutes                            sample_project_db_1
$ docker commit sample_project_db_1 dbmi/irct-db:mysql.5.7.22-irct.1.4.2c-with-resources

# update the version in your .env
$ ../tools/switchenv.sh --service db --version mysql.5.7.22-irct.1.4.2c-with-resources

$ docker-compose -f builddb.yml down
```

* * *

## Development

-   All production and debug ports are published.
-   Secrets in _your_project_`.secret` are deployed as Environment variables
-   Networks are unencrypted
-   **Development Volumes**: By default, code, executables, wars, etc. are persisted in a volume. You can link your development deployment with your local directory by setting the meta environment variables `LOCAL_IRCT`, `LOCAL_IRCT_CONFIG`, `LOCAL_WHITELIST_CONFIG`, `LOCAL_IRCT_SCRIPTS`, `LOCAL_NGINX_CONF` by updating `.env`:

    ```bash
    LOCAL_IRCT=/Local/path/to/irct/target
    LOCAL_NGINX_CONF=/Local/path/to/nginx/conf/templates
    LOCAL_IRCT_CONFIG=/Local/path/to/i2b2-wildfly/standalone/configuration/directory
    ```

-   **Development Database Port**: You can override the published Database by setting meta environment variable `DOCKER_DB_PORT` by updating `.env`:

    ```bash
    DOCKER_DB_PORT=3306
    ```

-   devlocaldb.yml
    -   local database with no volumes
-   dev.yml
    -   development deployment of irct services

```bash
$ cd deployments/irct
# setup your environment
$ ../tools/switchenv.sh --environment sample_project --type irct

$ docker-compose -f devlocaldb.yml -f dev.yml up -d
```

### Test query

JWT Token can be generated [here](https://github.com/hms-dbmi/jwt-creator.git)

Use `CLIENT_SECRET` value found in _your_project_`.secret` to generate your token.

Test query:

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Token>" \
-X GET https://<docker host>/rest/v1/systemService/about
```

### To stop and remove the stack

```bash
$ cd deployments/irct
$ docker-compose -f dev.yml down -v --remove-orphans
```

* * *

## Production

-   Production is only available in **Docker Swarm**
    -   Run `docker swarm init` to initialize your node as a Docker Swarm node.\\
-   Secrets in _your_project_`.secret` are depolyed with [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
-   Vault is available as a Secrets option using [secret-getter](https://github.com/hms-dbmi/secret-getter)
-   Networks are encrypted
-   Uses both open (access to outside world) and closed networks (no access to outside world)
-   Only published ports are 80, 443. You can override the published ports by setting meta environment variables `HTTP_PORT` and `HTTPS_PORT` by updating `.env`:

    ```bash
    HTTP_PORT=81
    HTTPS_PORT=444
    ```

-   proddb.yml
    -   Local database persisted in a volume connected to the rest of the stack in the closed network.
-   prod.yml
    -   production deployment of IRCT services

#### Using File Secrets

Place all your secrets in _your_project_`.secret` and run [switchenv.sh](https://github.com/hms-dbmi/docker-images/tools/switchenv.sh). File `/run/secrets/secret` maps to _your_project_`.secret` and used by `prod.yml`.

```bash
$ ../tools/switchenv.sh --environment your_project --type irct \
--secrets file --options "--path=/run/secrets/secret"
```

#### Using Vault Secrets

Place your Vault token in _your_project_`.secret`. _your_project_`.secret` must have **only** the Vault token, e.g. `00000000-0000-0000-000-00000000000`. Your token is available to the container in the file `/run/secrets/secret`

```bash
$ ../tools/switchenv.sh --environment your_project --type irct --secrets vault \
--options "--addr=https://your.vault.addr.com --token=/run/secrets/secret --path=/path/to/Vault/secrets/"
```

#### Deploy

```bash
$ cd docker-images/deployments/irct
# NOTE: RUN this command if you have not initialized Docker Swarm
$ docker swarm init

# setup your environment
$ ../tools/switchenv.sh --environment your_project --type irct

# deploy irct stack
$ docker-compose -f proddb.yml -f prod.yml up -d
```

### To stop and remove the stack

```bash
$ cd deployments/irct
# -v will remove any associated volumes with the stack
$ docker-compose -f prod.yml down -v --remove-orphans
```

* * *

## Additional Services

Additional services may be appended to the `dev.yml` and `prod.yml` stacks. Additional services may be found in `addons/` sub-directory.

**NOTE**: All addons assume its configuration variables and passwords are in the _same_ `.env` and `.secret` files as for your project, for example:

```bash
# sample_project.secret

# i2b2-wildfly database
DB_HOST=i2b2-db
DB_PORT=1521
DB_DB=ORCLPDB1

# i2b2-wildfly database user passwords
I2B2HIVE=demouser
I2B2DEMODATA=demouser
I2B2METADATA=demouser
I2B2PM=demouser
I2B2WORKDATA=demouser
```

#### Deploy i2b2-wildfly

-   If you are using a local i2b2 database, deploy the `addons/i2b2-db.yml` first

    ```bash
    $ docker-compose -f addons/i2b2-db.yml up -d

    # wait for database to start up
    $ docker-compose -f addons/i2b2-db.yml logs -f
    # i2b2-db_1            |#########################
    # i2b2-db_1            | DATABASE IS READY TO USE!
    # i2b2-db_1            | #########################
    ```

-   If you are using a _remote_ i2b2 database, update the `DB_HOST`, and any other relevant variables in _your_project_`.secret`, and then deploy only the `addons/i2b2-wildfly.yml`

    ```bash
    $ docker-compose -f addons/i2b2-wildfly.yml up -d
    ```

#### Deploy Splunk Forwarder

Populate _your_project_`.secret` with the following values:

```bash
# sample_project.secret
SPLUNK_USER=
SPLUNK_FORWARD_SERVER=
SPLUNK_FORWARD_SERVER_ARGS=--accept-license --no-prompt --answer-yes
SPLUNK_DEPLOYMENT_SERVER=
```

Then deploy:

```bash
$ docker-compose -f addons/splunk.yml up -d
```
