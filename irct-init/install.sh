#!/bin/bash
#POSIX

usage() {
    echo "Usage:"
    echo "  $0 [DATABASE ARGS] [RESOURCE] [options] [RESOURCE ARGS...]"
    echo "  $0 -h|--help"
    echo ""
    echo "Database Args:"
    echo "  -h, --host HOST             database host [default: \$IRCTMYSQLADDRESS]"
    echo "  -u, --user USER             database user [default: \$IRCT_DB_CONNECTION_USER]"
    echo "  -p, --password PASSWORD     database password [default: \$IRCTMYSQLPASS]"
    echo ""
    echo "Resources:"
    echo "  -r, --resource TYPE         resource to install"
    echo ""
    echo "Available Resource TYPE:"
    echo "  i2b2transmart-NAME"
    echo "  i2b2-wildfly-NAME"
    echo "  scidb-NAME"
    echo "  i2b2.org"
    echo "  dataconverters"
    echo "  monitor"
    echo ""
    echo "Options:"
    echo "  --delete  true|false        delete resource"
    echo "  --confirm true|false        confirm resource is installed [default: false]"
    echo ""
    echo "Resource Args:"
    echo "  i2b2transmart-NAME:"
    echo "  --resource-url URL          [required] i2b2transmart URL"
    echo "  --auth0-id CLIENT_ID        [required] Auth0 Client Id"
    echo "  --auth0-domain DOMAIN       [required] Auth0 Domain"
    echo "  --bucket NAME               AWS S3 bucket"
    echo ""
    echo "  i2b2-wildfly-NAME:"
    echo "  --simple true|false         count only install [default: false]"
    echo "  --resource-url URL          i2b2-wildfly URL [default: http://i2b2-wildfly:9090/i2b2/services/] "
    echo "  --resource-user USER        i2b2 user [default: demo]"
    echo "  --resource-pass PASSWORD    i2b2 password [default: demouser]"
    echo "  --resource-domain DOMAIN    i2b2 domain [default: i2b2demo]"
    echo ""
    echo "  scidb-NAME:"
    echo "  --resource-url URL          [required] SciDB host"
    echo "  --resource-user USER        [required] SciDB user"
    echo "  --resource-pass PASSWORD    [required] SciDB password"
    echo "  --afl-enabled true|false    use SciDB's Array Functional Language [default: false]"
    echo ""
    echo "Unavailable Resources:"
    echo "  hail"
    echo "  gnome"
    echo "  exac"
    echo ""

    if [ "$1" ]; then
        echo ""
        echo $1
    fi

    exit 1;
}

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

param() {
    case $1 in
        $3|$4)
            if [ "$2" ]; then
                echo "$2"
            else
                die "ERROR: "${4}" requires a non-empty option argument."
            fi
            ;;
    esac
}

host=${IRCTMYSQLADDRESS}
user=${IRCT_DB_CONNECTION_USER}
pass=${IRCTMYSQLPASS}
db=irct

simple=false
bucket=

confirm=false
delete=false

resource=
resourceurl=
resourceuser=
resourcepass=
resourcedomain=

auth0id=
auth0domain=

scidbafl=false

while :; do
    case $1 in
        -h|-\?|--help)
            usage    # Display a usage synopsis.
            exit $?
            ;;
        -h|--host)
            host=$(param $1 $2 "-h" "--host")
            ;;
        -u|--user)
            user=$(param $1 $2 "-u" "--user")
            ;;
        -p|--password)
            pass=$(param $1 $2 "-p" "--password")
            ;;
        -d|--database)
            db=$(param $1 $2 "-d" "--database")
            ;;
        -r|--resource)
            resource=$(param $1 $2 "-r" "--resource")
            ;;
        --confirm)
            confirm=$(param $1 $2 "--confirm" "--confirm")
            ;;
        --delete)
            delete=$(param $1 $2 "--delete" "--delete")
            ;;
        --resource-url)
            resourceurl=$(param $1 $2 "--resource-url" "--resource-url")
            ;;
        --simple)
            simple=$(param $1 $2 "--simple" "--simple")
            ;;
        --resource-user)
            resourceuser=$(param $1 $2 "--resource-user" "--resource-user")
            ;;
        --resource-domain)
            resourcedomain=$(param $1 $2 "--resource-domain" "--resource-domain")
            ;;
        --resource-pass)
            resourcepass=$(param $1 $2 "--resource-pass" "--resource-pass")
            ;;
        --bucket)
            bucket=$(param $1 $2 "--bucket" "--bucket")
            ;;
        --auth0-id)
            auth0id=$(param $1 $2 "--auth0-id" "--auth0-id")
            ;;
        --auth0-domain)
            auth0domain=$(param $1 $2 "--auth0-domain" "--auth0-domain")
            ;;
        --afl-enabled)
            scidbafl=$(param $1 $2 "--afl-enabled" "--afl-enabled")
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            die "ERROR: Unknown option: $1"
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
            ;;
    esac
    if [ "$2" ]; then
        shift
    fi
    shift
done


if [ -z "${host}" ] || [ -z "${user}" ] || [ -z "${pass}" ] || [ -z "${db}" ] || [ -z "${resource}" ]; then
    usage "ERROR: required: --host, --user, --password, --database, --resource"
fi

# confirm connection to database
echo "check IRCT DB connection"
{
    mysql --host=${host} --user=${user} --password=${pass} ${db} -e "SHOW SESSION STATUS LIKE 'Com_show_status';"
} || {
    exit $?
}

if [ "${confirm}" == "true" ]; then
    echo "confirm *only* IRCT DB populated"
    mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM Resource"
    exit $?
fi


if [ "${delete}" == "true" ]; then
    echo "--delete not yet implemented"
    exit $?
fi

{

# I2B2TranSMARTResource
if [[ "${resource}" =~ ^i2b2transmart\-(.+)$ ]]; then
    specificName="${BASH_REMATCH[1]}";

    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${specificName}'"`
    if [ ${count} -gt 0 ]; then
        echo "i2b2tranSMART Resource ${specificName} already exists"
    else
        if [ -z "${resourceurl}" ] || [ -z "${auth0id}" ] || [ -z "${auth0domain}" ]; then
            usage "ERROR: [required] --resource-url i2b2tranSMART URL --auth0-id CLIENT_ID --auth0-domain DOMAIN"
        fi

        echo "add i2b2tranSMART Resource to IRCT DB"
        mysql --host=${host} --user=${user} --password=${pass} ${db} -e "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''))"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
            "SET @resourceName='${specificName}'; \
            SET @auth0ClientId='${auth0id}'; \
            SET @auth0Domain='${auth0domain}'; \
            SET @transmartURL='${resourceurl}'; \
            SET @resourceURL='${resourceurl}/transmart/proxy?url=http://localhost:9090/i2b2/services/'; \
            source /scratch/irct/sql/resource/i2b2transmart/create.sql;"

        echo "confirm IRCT DB populated"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM Resource"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM resource_parameters WHERE name = 'resourceURL';"
        # AWS S3 bucket
        # Added extra character. bash can act weird with -n on empty strings
        if [ "x${bucket}" != x ]; then

            count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM event_parameters WHERE name='Bucket Name';"`
            if [ ${count} -gt 0 ]; then
                echo "AWS S3 Bucket configuration already exists"
            else
                mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
                "SET @resourceName='${specificName}'; \
                SET @S3BucketName='${bucket}'; \
                source /scratch/irct/sql/event/AWS-S3.sql;"

                echo "confirm S3 Bucket added"
                mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
                "SELECT * FROM event_parameters WHERE name='Bucket Name';"
            fi
        fi
        # end AWS S3 bucket
    fi
fi
# end I2B2Transmart


# Monitoring
if [ "${resource}" == "monitor" ]; then

    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM EventConverterImplementation WHERE name LIKE 'Monitoring%';"`
    if [ ${count} -gt 0 ]; then
        echo "Monitor configuration already exists"
    else
        mysql --host=${host} --user=${user} --password=${pass}  ${db}  < /scratch/irct/sql/event/Monitoring.sql

        echo "confirm Monitor added"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
          "SELECT * FROM EventConverterImplementation WHERE name LIKE 'Monitoring%';"
    fi


fi
# end Monitor

# data converters
if [ "${resource}" == "dataconverters" ]; then
    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e \
    "SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); \
    SELECT COUNT(*) FROM DataConverterImplementation;"`
    if [ ${count} -gt 0 ]; then
        echo "Data Converters already exist"
    else
        mysql --host=${host} --user=${user} --password=${pass}  ${db}  < /scratch/irct/sql/config/ResultDataConverters.sql
        echo "confirm Data Converters added"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
          "SELECT * FROM DataConverterImplementation;"
    fi

fi
# end data converters

# SciDB Resource
if [[ "${resource}" =~ scidb\-(.+)$ ]]; then
    specificName="${BASH_REMATCH[1]}";

    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${resource}'"`
    if [ ${count} -gt 0 ]; then
        echo "SciDB ${resource} already exists"
    else
        if [ -z "${resourceurl}" ] || [ -z "${resourceuser}" ] || [ -z "${resourcepass}" ]; then
            usage "ERROR: [required] --resource-url sciDB URL --resource-user sciDB user --resource-pass sciDB password"
        fi

        resourcetype="scidb"
        if [ "${scidbafl}" == "true" ]; then
            resourcetype="scidbafl"
        fi

        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
            "SET @resourceName='${resource}'; \
            SET @resourceURL='${resourceurl}'; \
            SET @userName='${resourceuser}'; \
            SET @password='${resourcepass}'; \
            source /scratch/irct/sql/resource/${resourcetype}/create.sql;"

            echo "confirm IRCT DB populated"
            mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM Resource"
    fi

fi
# end SciDB Resource

# i2b2.org Resource
if [ "${resource}" == "i2b2.org" ]; then
    # i2b2.org resource
    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = 'i2b2-i2b2-org'"`

    if [ ${count} -gt 0 ]; then
        echo "i2b2.org resource already exists"
    else
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
            "source /scratch/irct/sql/resource/i2b2passthrough/create.sql;"
        echo "confirm IRCT DB populated"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM Resource"
    fi
fi
# end i2b2.org Resource


# i2b2 local Resource
if [[ "${resource}" =~ ^i2b2\-wildfly\-(.+)$ ]]; then
    specificName="${BASH_REMATCH[1]}";

    count=`mysql --host=${host} --user=${user} --password=${pass} ${db} -ss -e "SELECT COUNT(*) FROM Resource WHERE name = '${resource}'"`
    if [ ${count} -gt 0 ]; then
        echo "i2b2 wildfly ${specificName} resource already exists"
    else
        resourcetype="i2b2"
        if [ "${simple}" == "true" ]; then
            resourcetype="i2b2_count_only"
            echo "add i2b2-wildfly ${specificName} resource (counts only) to IRCT DB"
        else
            echo "add i2b2-wildfly ${specificName} resource to IRCT DB"
        fi

        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e \
            "SET @resourceName ='${resource}'; \
            SET @resourceURL='${resourceurl}'; \
            SET @domain='${resourcedomain}'; \
            SET @userName='${resourceuser}'; \
            SET @password='${resourcepass}'; \
            source /scratch/irct/sql/resource/${resourcetype}/create.sql;"

        echo "confirm IRCT DB populated"
        mysql --host=${host} --user=${user} --password=${pass} ${db}  -e "SELECT * FROM Resource"
    fi

fi
# end i2b2 local resource
} || {
    exit $?
}




# TODO: Add UMLS Synonym and Capitalization initalization options
