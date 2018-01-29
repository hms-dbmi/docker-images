# i2b2: 1.7.09.001

## install i2b2 schema

- this database is already available as dbmi/i2b2-db:oracle.12.2.0.1-ee-i2b2.1.7.09
- TODO: create dbmi/transmart-db:postgres-i2b2.1.7.09

```
$ cd deployments/i2b2
$ export DB_TYPE=oracle [postgres]
$ export DB_VERSION=12.2.0.1-ee
$ docker-compose -f builddb.yml up -d db
$ docker-compose -f builddb.yml logs -f db
$ # wait until startup is complete
$ docker-compose -f builddb.yml run --rm schema "source vars; make -j4 oracle"
```

If you would like to save the database state, run `docker commit i2b2_db_1 dbmi/i2b2-db:oracle.12.2.0.1-ee-i2b2.1.7.09`

## deploy

```
$ cd deployments/i2b2
$ export DB_VERSION=oracle.12.2.0.1-ee-i2b2.1.7.09
$ docker-compose up -d
```
