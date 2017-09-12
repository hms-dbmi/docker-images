#!/bin/bash

usage() { echo "Usage: $0 [-h host] [-u user] [-p password] [-d database] optional: [-c (true|false) confirm only]" 1>&2; exit 1; }

while getopts ":h:u:p:d:c:" args; do
  case "${args}" in
    h)
      IRCTMYSQLADDRESS=${OPTARG}
      ;;
    u)
      IRCT_DB_CONNECTION_USER=${OPTARG}
      ;;
    p)
      IRCTMYSQLPASS=${OPTARG}
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

host=${IRCTMYSQLADDRESS}
user=${IRCT_DB_CONNECTION_USER}
pass=${IRCTMYSQLPASS}

if [ -z "${host}" ] || [ -z "${user}" ] || [ -z "${pass}" ] || [ -z "${db}" ]; then
    usage
fi

export MYSQL_PWD=${pass}

# confirm connection to database
echo "check IRCT DB connection"
{
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}
} || {
    exit $?
}

if [ "${confirm}" == "true" ]; then
    echo "confirm *only* IRCT DB populated"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
    exit $?
fi

{
    # I2B2TranSMARTResource
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${IRCT_RESOURCE_NAME}'"`
    if [ ${count} -gt 0 ]; then
        echo "I2B2TranSMARTResource already exists"
    else
        echo "add I2B2TranSMARTResource to IRCT DB"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @resourceName='${IRCT_RESOURCE_NAME}'; \
            SET @auth0ClientId='${AUTH0_CLIENT_ID}'; \
            SET @auth0Domain='${AUTH0_DOMAIN}'; \
            source /scratch/irct/sql/i2b2tranSMARTsetup.sql;"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user}  ${db}  < /scratch/irct/sql/ResultDataConverters.sql
        mysql --host=${IRCTMYSQLADDRESS} --user=${user}  ${db}  < /scratch/irct/sql/Monitoring.sql


    fi

    # only set if s3 env variable is set. Added extra character. bash can act weird with -n on empty strings
    if [ "x${S3_BUCKET_NAME}" != x ]; then
        # S3 Bucket Events
        count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM event_parameters;"`
        if [ ${count} -gt 0 ]; then
            echo "S3 Bucket configuration already exists"
        else
            mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @resourceName='${IRCT_RESOURCE_NAME}'; \
            SET @S3BucketName='${S3_BUCKET_NAME}'; \
            source /scratch/irct/sql/AWS-S3.sql;"
        fi

        echo "confirm S3 Bucket added"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
          "SELECT * FROM event_parameters;"
    fi

    # SciDBAFLResource
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = 'SciDBAFL'"`
    if [ ${count} -gt 0 ]; then
        echo "SciDBAFLResource already exists"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @sciDBHost='${SCIDB_HOST}'; \
            SET @sciDBUser='${SCIDB_USER}'; \
            SET @sciDBPassword='${SCIDB_PASSWORD}'; \
            source /scratch/irct/sql/ResourceInterface_SciDBAFL.sql;"
    fi

    echo "confirm IRCT DB populated"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"

} || {
    exit $?
}

# TODO: Add UMLS Synonym and Capitalization initalization options
