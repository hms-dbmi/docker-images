# PIC-SURE i2b2.org Resource Quick-Start

```
$ cd deployments/irct/quick-start
$ docker-compose up -d irct

# wait for database and irct to load
$ docker-compose logs -f irct

# initialize database
$ docker-compose run --rm irct-init -d irct -r i2b2

# restart irct
$ docker-compose restart irct
```
