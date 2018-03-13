# PIC-SURE i2b2.org Resource Quick-Start

```
$ cd deployments/irct/quick-start
$ docker-compose up -d irct

# wait for database and irct to load
$ docker-compose logs -f irct

# initialize database
$ docker-compose run --rm irct-init -d irct -r i2b2
$ docker-compose run --rm irct-init -d irct -r dataconverters

# restart irct
$ docker-compose restart irct
```

## Test PIC-SURE Access

JWT Token can be generated [here](https://github.com/hms-dbmi/jwt-creator.git)

Use AUTH0_CLIENT_SECRET value found in quick_start.env to generate your token.

Test query:

```
$ curl -k -i -L -H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <JWT Toke>" \
-X GET https://<docker host>/rest/v1/systemService/about
```
