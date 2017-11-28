#!/bin/bash
docker network create release-16.2

echo "run Oracle DB"
docker run -d -p 49160:22 -p 1521:1521 -e ORACLE_ALLOW_REMOTE=true --network release-16.2 --name transmartdb dtr.avl.dbmi.hms.harvard.edu/dbmi/oracle:base12c
sleep 20
docker exec transmartdb ./setPassword.sh password

echo "build Oracle client"
docker build -t dbmi/transmart-data:release-16.2 ./

echo "populate Oracle DB"
docker run --network release-16.2 --rm --name transmart-data dbmi/transmart-data:release-16.2


echo "save Oracle DB state"
sleep 10
docker commit transmartdb dtr.avl.dbmi.hms.harvard.edu/dbmi/oracle:release-16.2

docker stop transmartdb
docker rm transmartdb

docker network remove release-16.2
