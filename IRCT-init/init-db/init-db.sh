#!/bin/bash

usage() { echo "Usage: $0 [-h host] [-u user] [-p password] [-d database]" 1>&2; exit 1; }

while getopts ":h:u:p:d:" args; do
  case "${args}" in
    h)
      host=${OPTARG}
      ;;
    u)
      user=${OPTARG}
      ;;
    p)
      password=${OPTARG}
      ;;
    d)
      db=${OPTARG}
      ;;
    *)
      usage
      ;;
    esac
  done
shift $((OPTIND-1))

if [ -z "${host}" ] || [ -z "${user}" ] || [ -z "${password}"] || [ -z "${db}"]; then
    usage
fi

echo "populate IRCT DB"
mysql --host=${host} --user=${user} --password=${password} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
mysql --host=${host} --user=${user} --password=${password} ${db}  -e \
  "SET @resourceName='${IRCT_RESOURCE_NAME}'; \
  SET @auth0ClientId='${IRCT_AUTH0_CLIENT_ID}'; \
  SET @auth0Domain='${IRCT_AUTH0_DOMAIN}'; \
  source /scratch/irct/sql/i2b2tranSMARTsetup.sql;"
mysql --host=${host} --user=${user} --password=${password} ${db}  < /scratch/irct/sql/ResultDataConverters.sql
mysql --host=${host} --user=${user} --password=${password} ${db}  < /scratch/irct/sql/Monitoring.sql
echo "confirm IRCT DB populated"
mysql --host=${host} --user=${user} --password=${password} ${db}  -e "SELECT * FROM Resource"
