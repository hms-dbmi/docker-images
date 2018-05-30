# tranSMART

-   Latest Version: `release-16.2`
-   Features

    -   Dockerfiles are built similarly as [transmart-data](https://github.com/tranSMART-Foundation/transmart-data) + [scripts](https://github.com/tranSMART-Foundation/Scripts)
    -   alpine-based Dockerfiles
    -   encrypted network
    -   postgres (TODO) and oracle databases available
    -   self-signed certificates created by default, override wwith real certificates (TODO)

## Install database schema

-   TODO: create dbmi/transmart-db:postgres-tm.release-16.2
-   Database Available: `dbmi/transmart-db:oracle.12.2.0.1-ee-tm.release-16.3`

```bash
$ cd deployments/transmart
$ export db_type=oracle [postgres]
$ export db_version=12.2.0.1-ee
$ docker-compose -f builddb.yml up -d db
$ docker-compose -f builddb.yml logs -f db
$ # wait until startup is complete
$ docker-compose -f builddb.yml run --rm schema "source vars; make -j4 oracle"
```

## Load Datasets

-   Sample Database Available (GSE8581 Study): `dbmi/transmart-db:oracle-12.2.0.1-tm.release-16.3-GSE8581`

```bash
$ cd deployments/transmart
$ export db_type=oracle.12.2.0.1-ee-tm.release-16.3
$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_clinical_GSE8581"

$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_ref_annotation_GSE8581"
$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_expression_GSE8581"
$ docker-compose -f builddb.yml run --rm etl "source vars; make -C samples/oracle load_analysis_GSE8581"
```

If you would like to save the database state, run `docker commit transmart_db_1 dbmi/transmart-db:oracle.12.2.0.1-ee-tm.release-16.3-GSE8581`

## Deploy

```bash
$ cd deployments/transmart
$ docker-compose up -d
```

## passwords (TODO)
