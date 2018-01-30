# tranSMART: release-16.2

- Features

  - Dockerfiles are built similarly as transmart-data + scripts: <http://library.transmartfoundation.org/release/release16_2_0_artifacts/Scripts-release-16.2.zip>
  - alpine-based Dockerfiles
  - encrypted network
  - postgres (TODO) and oracle databases available
  - self-signed certificates created by default, override wwith real certificates (TODO)

## install database schema

- this database is already available as dbmi/transmart-db:oracle.12.2.0.1-ee-tm.release-16.2
- TODO: create dbmi/transmart-db:postgres-tm.release-16.2

```
$ cd deployments/transmart
$ export DB_TYPE=oracle [postgres]
$ export DB_VERSION=12.2.0.1-ee
$ docker-compose -f builddb.yml up -d db
$ docker-compose -f builddb.yml logs -f db
$ # wait until startup is complete
$ docker-compose -f builddb.yml run --rm schema "source vars; make -j4 oracle"
```

If you would like to save the database state, run `docker commit transmart_db_1 dbmi/transmart-db:oracle.12.2.0.1-ee-tm.release-16.2`

## load datasets (TODO: fix issue with ETL & Oracle 12)

```
$ cd deployments/transmart
$ export DB_TYPE=oracle.12.2.0.1-ee-tm.release-16.2
$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_clinical_GSE8581"

$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_ref_annotation_GSE8581"
$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_expression_GSE8581"
```

If you would like to save the database state, run `docker commit transmart_db_1 dbmi/transmart-db:oracle.12.2.0.1-ee-tm.release-16.2-GSE8581`

Sample database with GSE8581 available at dbmi/transmart-db:oracle-12.2.0.1-tm.release-16.2-GSE8581 (TODO: no longer exists. need to rebuild)

## deploy

```
$ cd deployments/transmart
$ export DB_VERSION=oracle-12.2.0.1-tm.release-16.2
$ docker-compose up -d
```

## passwords (TODO)
