#!/bin/bash

usage() { echo "Usage: $0 [-h host] [-u user] [-p password] [-d database] [-r resource] optional: [-c (true|false) confirm only]" 1>&2; exit 1; }

while getopts ":h:u:p:d:c:r:" args; do
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
    r)
      resource=${OPTARG}
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

if [ -z "${host}" ] || [ -z "${user}" ] || [ -z "${pass}" ] || [ -z "${db}" ] || [ -z "${resource}" ]; then
    echo "Available resources:"
    echo "i2b2transmart"
    echo "scidb"
    echo "i2b2"
    echo "dataconverters"
    echo "i2b2-wildfly"
    echo ""
    usage
fi

export MYSQL_PWD=${pass}

# confirm connection to database
echo "check IRCT DB connection"
{
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -e "SHOW SESSION STATUS"
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
if [ "${resource}" == "i2b2transmart" ]; then
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${IRCT_RESOURCE_NAME}'"`
    if [ ${count} -gt 0 ]; then
        echo "I2B2TranSMARTResource already exists"
    else
        echo "add I2B2TranSMARTResource to IRCT DB"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @resourceName='${IRCT_RESOURCE_NAME}'; \
            SET @auth0ClientId='${CLIENT_ID}'; \
            SET @auth0Domain='${AUTH0_DOMAIN}'; \
            SET @transmartURL='${EXTERNAL_URL}'; \
            SET @resourceURL='${EXTERNAL_URL}/transmart/proxy?url=http://localhost:9090/i2b2/services/'; \
            source /scratch/irct/sql/i2b2tranSMARTsetup.sql;"
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
fi
# end I2B2Transmart

# data converters
if [ "${resource}" == "dataconverters" ]; then
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e \
    "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); \
    SELECT COUNT(*) FROM DataConverterImplementation;"`
    if [ ${count} -gt 0 ]; then
        echo "Data Converters already exist"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user}  ${db}  < /scratch/irct/sql/ResultDataConverters.sql
    fi
    echo "confirm Data Converters added"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
      "SELECT * FROM DataConverterImplementation;"
fi
# end data converters

# SciDBAFLResource
if [ "${resource}" == "scidb" ]; then
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
fi
# end SciDBAFLResource

# I2B2 Resource
if [ "${resource}" == "i2b2" ]; then
    # i2b2.org resource
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = 'i2b2-i2b2-org'"`

    if [ ${count} -gt 0 ]; then
        echo "i2b2 resource already exists"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "source /scratch/irct/sql/ResourceInterface_i2b2.sql;"
    fi

    echo "confirm IRCT DB populated"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
fi
# end I2B2 Resource


# I2B2 local Resource
if [ "${resource}" == "i2b2-wildfly-${IRCT_RESOURCE_NAME}" ]; then
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${IRCT_RESOURCE_NAME}'"`
    if [ ${count} -gt 0 ]; then
        echo "i2b2-wildfly-${IRCT_RESOURCE_NAME} resource already exists"
    else
        echo "add i2b2-wildfly resource to IRCT DB"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @resourceName ='i2b2-wildfly-${IRCT_RESOURCE_NAME}'; \
            source /scratch/irct/sql/i2b2setup.sql;"
    fi

    echo "confirm IRCT DB populated"
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
fi
# end I2B2 local resource
} || {
    exit $?
}




# TODO: Add UMLS Synonym and Capitalization initalization options
