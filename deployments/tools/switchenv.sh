#!/bin/bash
#POSIX

usage() {
    echo "Usage:"
    echo "  source switchenv.sh [ARGS]"
    echo "  source switchenv.sh -h|--help"
    echo ""
    echo "Enviornment Arguments:"
    echo "  -e, --environment ENV           [required] Project to deploy."
    echo "                                  [prerequisite] Matching <ENV>.env file in current directory."
    echo ""
    echo "  -t, --type transmart|irct       [required] Deployment types. Determines Database type."
    echo ""
    echo ""
    echo "  -r, --remote true|false         Enables ssh-tunneling for remote database use [default: false]."
    echo "                                  [prerequisite] ssh-agent."
    echo "                                  [prerequisite] Matching ssh config option <ENV> in /.ssh/config."
    echo ""
    echo "Secrets Arguments:"
    echo "  -s, --secrets vault|file|none   Secrets Vault to use [default: none]"
    echo ""
    echo "  --path PATH                     PATH to Vault token (vault), PATH to encrypted secrets (file)"
    echo ""
    echo "Service Versioning Arguments:"
    echo ""
    echo "  --service SERVICE               Modify SERVICE to deploy."
    echo ""
    echo "  -v, --version VERSION           Set SERVICE VERSION to deploy. Overrides default VERSION in .env"
    echo ""
    echo "Other Arguments:"
    echo "  --dry-run true|false            Dry run deployment settings [default: false]."
    echo ""
    echo ""

    if [ "$1" ]; then
        echo ""
        echo $1
    fi

    return 1;
}

die() {
    printf '%s\n' "$1" >&2
    return 1
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

env=
type="transmart"
remote="false"
secrets=
path=
service=
version=
confirm="false"

while :; do
    case $1 in
        -h|-\?|--help)
            usage    # Display a usage synopsis.
            return $?
            ;;
        -e|--environment)
            env=$(param $1 $2 "-e" "--environment")
            ;;
        -t|--type)
            type=$(param $1 $2 "-t" "--type")
            ;;
        -s|--secrets)
            secrets=$(param $1 $2 "-s" "--secrets")
            ;;
        -p|--path)
            path=$(param $1 $2 "-p" "--path")
            ;;
        -r|--remote)
            remote=$(param $1 $2 "-r" "--remote")
            ;;
        --service)
            service=$(param $1 $2 "--service" "--service")
            ;;
        -v|--version)
            version=$(param $1 $2 "-v" "--version")
            ;;
        --dry-run)
            confirm=$(param $1 $2 "--dry-run" "--dry-run")
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

if [ -z "${env}" ] || [ -z "${type}" ]; then
    usage "ERROR: required: --environment, --type"
    return 1
fi

if [ -z "${DOCKER_HOST}" ]; then
    echo "Connecting to Docker $(docker-machine env default)"
    eval $(docker-machine env default)
fi

unset DOCKER_CONTENT_TRUST

if [ "${remote}" == "true" ]; then
    echo "Forward ssh-agent to docker-machine"
    echo ""
    # TODO: We are assuming ssh-agent is 1 or 2 directories above our current pwd -Andre
    eval "../../ssh-agent/pinata-ssh-forward.sh" 2> /dev/null
    eval "../ssh-agent/pinata-ssh-forward.sh" 2> /dev/null
    echo ""

    echo "Test ssh connection"
    eval "ssh -q ${env} return"
    ret=$?
    if [ $ret != 0 ]; then
        echo "ERROR: Could not ssh into ${env} ($ret). Check ssh configuration file."
        usage
        return 1
    else
        echo "SUCCESS"
        echo ""
    fi
fi

echo "Using ${env}.env"
echo ""
if [ ! -f "${env}.env" ]; then
    echo "ERROR: ${env}.env does not exist"
    usage
    return 1
fi

echo "Setting up ${type}"
echo ""
regex=""
if [ "${type}" == "transmart" ]; then
    regex="(ORACLEHOST|DB_HOST)=(.*)"
elif [ "${type}" == "irct" ]; then
    regex="(IRCTMYSQLADDRESS)=(.*)"
else
    echo "ERROR: Deployment type ${type} not available. [Available: transmart|irct]"
    usage
    return 1
fi

# TODO: requires testing -Andre
# find database first in secrets
while read line; do
    if [[ $line =~ $regex ]]; then
        db_var="${BASH_REMATCH[1]}"
        db_host="${BASH_REMATCH[2]}"
        break
    fi
done < "${env}.secret"

# find database in env file
while read line; do
    if [[ $line =~ $regex ]]; then
        db_var="${BASH_REMATCH[1]}"
        db_host="${BASH_REMATCH[2]}"
        break
    fi
done < "${env}.env"

if [ -z "${db_host}" ]; then
    echo "ERROR: Could not find database host (${regex}) in ${env}.secret or ${env}.env"
    usage
    return 1
fi


if [[ $(docker ps --format "{{.Names}} {{.Ports}}" | grep -s "\->") ]]; then
    echo "***** WARNING *****"
    echo "Docker host bound ports still up."
    echo "There may be possible port conflicts."
    eval 'docker ps --format "{{.Names}} {{.Ports}}" | grep -s "\->"'
    echo "***** WARNING ****"
    echo ""
fi

echo "# Environment Variables"
if [ "${confirm}" == "true" ]; then
    echo "**** DRY RUN ONLY ***"
fi

echo ""
echo "COMPOSE_PROJECT_NAME=${env}"
echo "ENV_FILE=${env}.env"
echo "SSH_CONFIG_CONFIG=${env}"
echo "STACK_NAME=${env}"
echo ""
if [ "${confirm}" != "true" ]; then
    export COMPOSE_PROJECT_NAME=$env
    export ENV_FILE=$env.env
    export SSH_CONFIG_CONFIG=$env
    export STACK_NAME=$env
fi

echo "# database"
echo "${db_var}=${db_host}"
echo ""
export $db_var=$db_host

if [ "x${secrets}" != "x" ] && [ "x${path}" != "x"]; then
    echo "# secrets"
    echo "SG_COMMAND=${secrets}"
    echo "SG_OPTIONS=${path}"
    echo ""
    if [ "${confirm}" != "true" ]; then
        export SG_COMMAND=${secrets}
        export SG_OPTIONS=${path}
    fi
else
    echo "ERROR: Both --secrets and --path must be provided"
    usage
    return 1
fi

if [ "x${service}" != "x" ] && [ "x${version}" != "x" ]; then
    echo "# service version"
    echo "${service}_version=${version}"
    echo ""
    if [ "${confirm}" != "true" ]; then
        export ${service}_version=${version}
    fi
else
    echo "ERROR: Both --service and --version must be provided"
    usage
    return 1
fi



return 0
