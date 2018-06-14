# i2b2/tranSMART Deployment

* * *

## Configuration

1.  Create a project env file. These are for non-secret environment configurations There is an example `sample_project.env`
2.  Create a secrets env file.  These are for secrets, including database passwords. There is an example `sample_secrets.env`
3.  Update `.env` with the desired service versions. By default `.env` is setup to deploy the `sample_project` stack

* * *

## Setup your Environment

Use `../tools/switchenv.sh` to setup the environment.

-   overrides default service versions found in `.env`
-   setups ssh-tunneling to a remote database
-   setups secrets

```bash
Usage:
  source switchenv.sh [ARGS]
  source switchenv.sh -h|--help

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
$ source ../tools/switchenv.sh --service i2b2transmart --version release-18.1-beta-7

# service version
# i2b2transmart_version=release-18.1-beta-7

# ####
# setup ssh forward agent
# ####
$ source ../tools/switchenv.sh --remote true -e sample_project --type transmart

# Forward ssh-agent to docker-machine
#
# ssh-agent
# Agent forwarding successfully started.
# Run "pinata-ssh-mount" to get a command-line fragment that
# can be added to "docker run" to mount the SSH agent socket.
#
# For example:
# docker run -it $(pinata-ssh-mount) uber/ssh-agent-forward ssh -T git@github.com
#
# Test ssh connection
# SUCCESS
# ####
# setup envirment for sample_project deployment with file secrets
# ####
$ source ../tools/switchenv.sh --environment sample_project --type transmart --secrets file --options "--path=/run/secrets/secret"

# Using sample_project.env
#
# Using sample_project.secret
#
# Setting up transmart
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
# DB_HOST=db
#
# # secrets
# SG_COMMAND=file
# SG_OPTIONS=--path=/run/secrets/secret
```

* * *

## Development

-   All production and debug ports are published.
-   Secrets in _your_project_`.secret` are deployed as Environment variables
-   Networks are unencrypted
-   By default, code, executables, wars, etc. are persisted in a volume. You can link your development deployment with your local directory by setting the meta environment variable `LOCAL_TRANSMART`:

    ```bash
    $ export LOCAL_TRANSMART=/Local/path/to/transmart-war/target/
    ```

    _OR_ append to `.env`:

    ```bash
    LOCAL_TRANSMART=/Local/path/to/transmart-war/target
    ```

-   devlocaldb.yml
    -   local database with no volumes
-   devremotedb.yml
    -   ssh-tunnel to remote database
-   dev.yml
    -   development deployment of i2b2transmart services

```bash
$ cd deployments/i2b2transmart
$ source ../tools/switchenv.sh --environment sample_project --type transmart
$ docker-compose -f devlocaldb.yml -f devdb.yml up -d db
# wait for database to load
$ docker-compose -f devlocaldb.yml -f devdb.yml up -d
```

* * *

## Production

-   Production is only available in Docker Swarm
-   Secrets in _your_project_`.secret` are depolyed with [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
-   Vault is available as a Secrets option using [secret-getter](https://github.com/hms-dbmi/secret-getter)
-   Networks are encrypted
-   Uses both open (access to outside world) and closed networks (no access to outside world)
-   Only published ports are 80, 443. You can override the published ports by setting meta environment variables `HTTP_PORT` and `HTTPS_PORT`:
    ```bash
    $ export HTTP_PORT=81
    $ export HTTPS_PORT=443
    ```
      _OR_ append to `.env`:
    ```bash
    HTTP_PORT=81
    HTTPS_PORT=444
    ```
-   proddb.yml
    -   Local database persisted in a volume connected to the rest of the stack in the closed network.
-   prod.yml
    -   production deployment of i2b2transmart services

### Notes

-   If you plan to use Vault, _your_project_`.secret` must have _only_ the Vault token, e.g. `00000000-0000-0000-000-00000000000`
-   You must use Docker Swarm: `docker swarm init`

```bash
$ cd depolyments/i2b2transmart
$ source ../tools/switchenv.sh --environment sample_project --type transmart --secrets vault --options "--addr=https://your.vault.addr.com --token=/run/secrets/secret --path=/path/to/vault/secrets/"
$ docker-compose -f proddb.yml -f prod.yml up -d db
# wait for database to load
$ docker-compose -f proddb.yml -f prod.yml up -d
```
