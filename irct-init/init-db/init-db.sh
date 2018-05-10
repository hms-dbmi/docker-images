#!/bin/bash

usage() {
    echo "Usage: $0 -h host -u user -p password -d database -r resource"
    echo "options:"
    echo "-e external URL       required: for i2b2transmart Resource"
    echo "-b bucket name        optional: for i2b2transmart Resource. add AWS S3 bucket"
    echo "-s true|false         optional: for i2b2-wildfly Resource. Simple install only"
    echo "-c true|false         optional: confirms Resource is installed"
    echo ""
    echo ""
    echo "Available resources:"
    echo "i2b2transmart-[name of resource]"
    echo "scidb"
    echo "i2b2.org"
    echo "dataconverters"
    echo "i2b2-wildfly-[name of resource]"
    echo "monitor"
    echo ""
    echo "ex: irct-init.sh -h localhost -u mysql_user -p password -d irct -r i2b2-wildfly-demo"
    exit 1;
}

while getopts ":h:u:p:d:c:r:e:s:b:" args; do
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
    e)
      externalUrl=${OPTARG}
      ;;
    s)
      simple=${OPTARG}
      ;;
    b)
      bucket=${OPTARG}
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
    usage
fi

export MYSQL_PWD=${pass}

# confirm connection to database
echo "check IRCT DB connection"
{
    mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -e "SHOW SESSION STATUS LIKE 'Com_show_status';"
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
if [[ "${resource}" =~ ^i2b2transmart\-(.+)$ ]]; then
    specificName="${BASH_REMATCH[1]}";

    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${specificName}'"`
    if [ ${count} -gt 0 ]; then
        echo "i2b2tranSMART Resource ${specificName} already exists"
    else
        if [ -z "${externalUrl}" ]; then
            echo "ERROR: i2b2tranSMART URL required"
            echo ""
            usage
        fi

        echo "add i2b2tranSMART Resource to IRCT DB"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "SET @resourceName='${specificName}'; \
            SET @auth0ClientId='${CLIENT_ID}'; \
            SET @auth0Domain='${AUTH0_DOMAIN}'; \
            SET @transmartURL='${externalUrl}'; \
            SET @resourceURL='${externalUrl}/transmart/proxy?url=http://localhost:9090/i2b2/services/'; \
            source /scratch/irct/sql/i2b2tranSMARTsetup.sql;"

        echo "confirm IRCT DB populated"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM resource_parameters WHERE name = 'resourceURL';"
        # AWS S3 bucket
        # Added extra character. bash can act weird with -n on empty strings
        if [ "x${bucket}" != x ]; then

            count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM event_parameters WHERE name='Bucket Name';"`
            if [ ${count} -gt 0 ]; then
                echo "AWS S3 Bucket configuration already exists"
            else
                mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
                "SET @resourceName='${specificName}'; \
                SET @S3BucketName='${bucket}'; \
                source /scratch/irct/sql/AWS-S3.sql;"

                echo "confirm S3 Bucket added"
                mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
                "SELECT * FROM event_parameters WHERE name='Bucket Name';"
            fi
        fi
        # end AWS S3 bucket
    fi
fi
# end I2B2Transmart


# Monitoring
if [ "${resource}" == "monitor" ]; then

    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM EventConverterImplementation WHERE name LIKE 'Monitoring%';"`
    if [ ${count} -gt 0 ]; then
        echo "Monitor configuration already exists"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user}  ${db}  < /scratch/irct/sql/Monitoring.sql

        echo "confirm Monitor added"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
          "SELECT * FROM EventConverterImplementation WHERE name LIKE 'Monitoring%';"
    fi


fi
# end Monitor

# data converters
if [ "${resource}" == "dataconverters" ]; then
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e \
    "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); \
    SELECT COUNT(*) FROM DataConverterImplementation;"`
    if [ ${count} -gt 0 ]; then
        echo "Data Converters already exist"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user}  ${db}  < /scratch/irct/sql/ResultDataConverters.sql
        echo "confirm Data Converters added"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
          "SELECT * FROM DataConverterImplementation;"
    fi

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

            echo "confirm IRCT DB populated"
            mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
    fi

fi
# end SciDBAFLResource

# i2b2.org Resource
if [ "${resource}" == "i2b2.org" ]; then
    # i2b2.org resource
    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = 'i2b2-i2b2-org'"`

    if [ ${count} -gt 0 ]; then
        echo "i2b2.org resource already exists"
    else
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
            "source /scratch/irct/sql/ResourceInterface_i2b2.sql;"
        echo "confirm IRCT DB populated"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
    fi
fi
# end i2b2.org Resource


# i2b2 local Resource
if [[ "${resource}" =~ ^i2b2\-wildfly\-(.+)$ ]]; then
    specificName="${BASH_REMATCH[1]}";

    count=`mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${resource}'"`
    if [ ${count} -gt 0 ]; then
        echo "i2b2 wildfly ${specificName} resource already exists"
    else
        if [ "${simple}" == "true" ]; then

            echo "add i2b2-wildfly ${specificName} resource (counts only) to IRCT DB"
            mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
                "SET @resourceName ='${resource}'; \
                source /scratch/irct/sql/i2b2_count_only_setup.sql;"
        else
            echo "add i2b2-wildfly ${specificName} resource to IRCT DB"
            mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e \
                "SET @resourceName ='${resource}'; \
                source /scratch/irct/sql/i2b2setup.sql;"
        fi

        echo "confirm IRCT DB populated"
        mysql --host=${IRCTMYSQLADDRESS} --user=${user} ${db}  -e "SELECT * FROM Resource"
    fi

fi
# end i2b2 local resource
} || {
    exit $?
}




# TODO: Add UMLS Synonym and Capitalization initalization options
