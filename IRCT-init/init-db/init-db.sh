#!/bin/bash

usage() { echo "Usage: $0 [-h host] [-u user] [-p password] [-d database] optional: [-c (true|false) confirm only]" 1>&2; exit 1; }

while getopts ":h:u:p:d:c:" args; do
  case "${args}" in
    h)
      IRCTMYSQLADDRESS=${OPTARG}
      host=${IRCTMYSQLADDRESS}
      ;;
    u)
      user=${OPTARG}
      ;;
    p)
      IRCTMYSQLPASS=${OPTARG}
      pass=${IRCTMYSQLPASS}
      ;;
    d)
      db=${OPTARG}
      ;;
    c)
      confirm=${OPTARG}
      ;;
    *)
      usage
      ;;
    esac
  done
shift $((OPTIND-1))

if [ -z "${host}" ] || [ -z "${user}" ] || [ -z "${pass}" ] || [ -z "${db}" ]; then
    usage
fi

if [ "${confirm}" == "true" ]; then
    echo "confirm IRCT DB populated"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db}  -e "SELECT * FROM Resource"
    exit
fi

echo "populate IRCT DB"
mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db}  -e \
  "SET @resourceName='${IRCT_RESOURCE_NAME}'; \
  SET @auth0ClientId='${AUTH0_CLIENT_ID}'; \
  SET @auth0Domain='${AUTH0_DOMAIN}'; \
  source /scratch/irct/sql/i2b2tranSMARTsetup.sql;"
mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db}  < /scratch/irct/sql/ResultDataConverters.sql
mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db}  < /scratch/irct/sql/Monitoring.sql
echo "confirm IRCT DB populated"
mysql --host=${IRCTMYSQLADDRESS} --user=${user} --password=${IRCTMYSQLPASS} ${db}  -e "SELECT * FROM Resource"
