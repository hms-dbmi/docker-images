# PIC-SURE

This environment contains a PICSURE-2.0 layer, 2 IRCT resources, and an I2B2-wildfly.  Each has its own database.  PICSURE-2.0 can call either of the 2 IRCTs, which both query the I2B2-wildfly.

Note: This environment uses a LOT of memory.

All services in this container:
- nginx
- dockergen
- picsure2
- picsuredb
- i2b2-wildfly
- oracle-db
- irct1
- irct-db-1
- irct2
- irct-db-2


## Versioning

Latest available Docker image versions:

-   dbmi/nginx:alpine-tmpl.1.0
-   dbmi/irct: 1.4.2.tokenIntro
-   dbmi/irct-db: mysql.5.7.22-irct.1.4.2-i2b2-wildfly
-   dbmi/i2b2-db: oracle.12.2.0.1-ee-i2b2.1.7.09
-   dbmi/i2b2-wildfly: 1.7.09c
-   dbmi/picsure2: 0.0.0.irct_included2
-   dbmi/picsure-db: mysql.5.7.22-irct-and-user

# How To Deploy

This project assumes you already have docker and docker-compose installed.
If you have been using docker with other projects, you may want to create a separate docker machine to run this project.  
If you don't have docker-machine installed, see instructions [here](https://docs.docker.com/machine/install-machine/).

 ```bash
 #create a machine named 'grinmachine' with default settings and virtualbox driver
 $ docker-machine create -d virtualbox grinmachine
 #switch your shell to your new machine
 $ eval "$(docker-machine env grinmachine)"
 ```

See the [documentation](https://docs.docker.com/machine/get-started/#create-a-machine) for more details.

## Env Files

-   _Required_: `*_version=`, `IRCTMYSQLADDRESS=`, `ENV_FILE=`, `IRCT1_ENV_FILE=`, `IRCT2_ENV_FILE`.

-   Optional: `STACK_ENV=`, `STACK_NAME`.

```bash
## versions
nginx_version=alpine-tmpl.1.0
irct_version=1.4.2.tokenIntro
irct_db_version=mysql.5.7.22-irct.1.4.2-i2b2-wildfly
oracle_db_version=oracle.12.2.0.1-ee-i2b2.1.7.09
picsure2_version=0.0.0.irct_included2
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
```

Existing `.env` files should not need to be modified.

## Deploy


```bash
 $ cd deployments/grin
 $ docker-compose up -d
```

Show logs:

`$ docker-compose logs -f`

You can also view only the logs of the containers you are interested in, for example, picsure2:

```bash
$ docker-compose logs -f picsure2
#picsure2_1      | 13:30:22,999 INFO  [org.wildfly.extension.undertow] (ServerService Thread Pool -- 72) WFLYUT0021: Registered web context: '/pic-sure-api-2' for server 'default-server'
#picsure2_1      | 13:30:23,026 INFO  [org.jboss.as.server] (ServerService Thread Pool -- 39) WFLYSRV0010: Deployed "pic-sure-api-2.war" (runtime-name : "pic-sure-api-2.war")
#picsure2_1      | 13:30:23,027 INFO  [org.jboss.as.server] (ServerService Thread Pool -- 39) WFLYSRV0010: Deployed "pic-sure-irct-resource.war" (runtime-name : "pic-sure-irct-resource.war")
#picsure2_1      | 13:30:23,344 INFO  [org.jboss.as.server] (Controller Boot Thread) WFLYSRV0212: Resuming server
#picsure2_1      | 13:30:23,347 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0060: Http management interface listening on http://127.0.0.1:9990/management
#picsure2_1      | 13:30:23,347 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://127.0.0.1:9990
#picsure2_1      | 13:30:23,348 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0025: WildFly Full 13.0.0.Final (WildFly Core 5.0.0.Final) started in 41646ms - Started 508 of 699 services (321 services are lazy, passive or on-demand)
```

Or irct1:

```bash
$ docker-compose logs -f irct1
#irct1_1         | 13:30:31,630 INFO  [org.wildfly.extension.undertow] (ServerService Thread Pool -- 73) WFLYUT0021: Registered web context: /IRCT-CL
#irct1_1         | 13:30:31,666 INFO  [org.jboss.as.server] (ServerService Thread Pool -- 34) WFLYSRV0010: Deployed "IRCT-CL.war" (runtime-name : "IRCT-CL.war")
#irct1_1         | 13:30:31,788 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0060: Http management interface listening on http://127.0.0.1:9990/management
#irct1_1         | 13:30:31,789 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://127.0.0.1:9990
#irct1_1         | 13:30:31,789 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0025: WildFly Full 10.1.0.Final (WildFly Core 2.2.0.Final) started in 49698ms - Started 649 of 884 services (406 services are lazy, passive or on-demand)
```


## Generate JWT token

A test user with email foo@bar.com is already installed in the system.  To use PICSURE-2.0 you need an authorization token that identifies an authorized user.  
You can generate a JWT token with the `PIC_SURE_CLIENT_SECRET` (set to 'secret' by default) in the environment file with [JWT Creator](https://github.com/hms-dbmi/jwt-creator.git):
- Build the project
- cd into the target folder
- create a text file containing only the `PIC_SURE_CLIENT_SECRET`
- `$ java -jar generateJwt.jar <path to file with secret> email foo@bar.com 999999`

Or go to [jwt.io](https://jwt.io/) and replace 'email' with 'foo@bar.com' and enter your secret into the secret box, using algorithm HS256, and a token should be generated for you.

## Test PIC-SURE Access

Run
`$ docker-machine ip`
to find out the ip of your docker host.

You can store this and your JWT token in your shell environment:
```bash
$ export DOCKERHOST=`docker-machine ip`
$ export JWT_TOKEN="dj34t93gw92jghio23tgnh.fq2g340"
```

See available resources. 2 IRCTs should already be installed.

```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${JWT_TOKEN}" \
-X GET https://${DOCKERHOST}/picsure2/pic-sure-api-2/PICSURE/info/resources
```

You can access the swagger.json for information about what endpoints are available:
```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${JWT_TOKEN}" \
-X GET https://${DOCKERHOST}/picsure2/pic-sure-api-2/PICSURE/swagger.json
```

Additional users can be added (both `userId` and `subject` can be the email address):
```bash
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${JWT_TOKEN}" \
-X POST --data '{"userId" : "<userId>", "subject" : "<userId>", "roles" : "ROLE_INTROSPECTION_USER" }' \
https://${DOCKERHOST}/picsure2/pic-sure-api-2/PICSURE/user
```

Further information on PICSURE-2.0 is located [here](https://github.com/hms-dbmi/pic-sure)


## Shutdown PIC-SURE

Any docker-compose yaml will shutdown the services in their stack.
`$ docker-compose down`
If you would like to remove _all_ services, add option `--remove-orphans`
`$ docker-compose down --remove-orphans`
