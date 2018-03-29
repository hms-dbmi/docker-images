#!/bin/bash
usage() { echo "
    Usage: switchenv.sh [-e environment] [-d (transmart|irct)] optional: [-s (true|false)]
    -e: environment/project name
    -d: deployment application stack
    -s: enable ssh-tunnel

    e.g. source switchenv.sh -e sample_project -d transmart

    Your ssh configuration in ~/.ssh/config and your project env *must* have the same name,
    e.g. ssh sample_project, sample_project.env

    To forward you ssh-agent for remote ssh-tunneling, set argument -s true
    e.g. source switchenv.sh -e sample_project -d transmart -s true"
    return 1;
}

OPTIND=1

ssh_agent="false"

while getopts ":e:d:s:" args; do
  case "${args}" in
    e)
      env=${OPTARG}
      ;;
    d)
      deploy_type=${OPTARG}
      ;;
    s)
      ssh_agent=${OPTARG}
      ;;
    \?)
      echo "ERROR: Invalid option: -$OPTARG"
      return 1
      ;;
    :)
      echo "ERROR: Option -$OPTARG requires an argument"
      return 1
      ;;
    *)
      usage
      return 1
      ;;
    esac
  done
shift $((OPTIND-1))

if [ -z "${DOCKER_HOST}" ]; then
    echo "Connecting to Docker $(docker-machine env default)"
    eval $(docker-machine env default)
fi

unset DOCKER_CONTENT_TRUST

if [ "${ssh_agent}" == "true" ]; then
    echo "Forward ssh-agent to docker-machine"
    echo ""
    # TODO: We are assuming ssh-agent is 1 or 2 directories above our current pwd -Andre
    eval "../../ssh-agent/pinata-ssh-forward.sh" 2> /dev/null
    eval "../ssh-agent/pinata-ssh-forward.sh" 2> /dev/null
    echo ""

    echo "Test ssh connection"
    eval "ssh -q ${env} exit"
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

regex=""

if [ "${deploy_type}" == "transmart" ]; then
    regex="(ORACLEHOST|DB_HOST)=(.*)"
elif [ "${deploy_type}" == "irct" ]; then
    regex="(IRCTMYSQLADDRESS)=(.*)"
else
    usage
    return 1
fi

if [ ! -f "${env}.env" ]; then
    echo "ERROR: ${env}.env does not exist"
    usage
    return 1
fi

while read line; do
    if [[ $line =~ $regex ]]; then
	db_var="${BASH_REMATCH[1]}"
        db_host="${BASH_REMATCH[2]}"
        break
    fi
done < "${env}.env"

if [ -z "${db_host}" ]; then
    echo "ERROR: Could not find database host (${regex}) in ${env}.env"
    usage
    return 1
fi

if [[ $(docker ps --format "{{.Names}} {{.Ports}}" | grep -s ${COMPOSE_PROJECT_NAME} | grep -s "\->") ]]; then
    echo "WARNING: Previous project has docker host bound ports still up."
    echo "WARNING: There may be possible port conflicts."
    eval 'docker ps --format "{{.Names}} {{.Ports}}" | grep ${COMPOSE_PROJECT_NAME} | grep "\->"'
fi

echo ""
echo "COMPOSE_PROJECT_NAME=${env}"
echo "ENV_FILE=${env}.env"
echo "SSH_CONFIG_CONFIG=${env}"
echo "${db_var}=${db_host}"

export COMPOSE_PROJECT_NAME=$env
export ENV_FILE=$env.env
export SSH_CONFIG_CONFIG=$env
export $db_var=$db_host

return 0
