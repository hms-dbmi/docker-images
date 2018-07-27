#!/bin/bash
#POSIX
usage() {
    echo "Usage:"
    echo "  destroy.sh [ARGS]"
    echo "  destroy.sh -h|--help"
    echo ""
    echo "Arguments:"
    echo "  -a, --all true|false        Stop and remove all containers, volumes, and dangling images [default: false]"
    echo "  -i, --images true|false     Remove dangling images [default: false]"
    echo "  -n, --networks true|false   Remove danlging networks [default: false]"
    echo ""
    echo "Environment Arguments:"
    echo "  -e, --environment ENV       Project ENV containers to destroy."
    echo "  -v, --volumes true|false    Remove all volumes for ENV [default: false]"
    echo ""
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

# destroy everything
destroy_all="false"

# env to destroy
env=

# destroy containers
# always true
destroy_containers="true"

# destroy volumes
destroy_volumes="false"

# destroy images
destroy_images="false"

# destroy networks
destroy_networks="false"


while :; do
    case $1 in
        -h|-\?|--help)
            usage    # Display a usage synopsis.
            exit $?
            ;;
        -e|--environment)
            env=$(param $1 $2 "-e" "--environment")
            ;;
        -v|--volumes)
            destroy_volumes=$(param $1 $2 "-v" "--volumes")
            ;;
        -n|--networks)
            destroy_networks=$(param $1 $2 "-n" "--networks")
            ;;
        -i|--images)
            destroy_images=$(param $1 $2 "-i" "--images")
            ;;
        -a|--all)
            destroy_all=$(param $1 $2 "-a" "--all")
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


#### Everything ####
if [ "${destroy_all}" == "true" ]; then
    echo "Stop and remove all containers and associated volumes"
    echo ""
    eval "docker ps -a -q | xargs -L1 docker stop"
    eval "docker ps -a -q | xargs -L1 docker rm -v -f"
    ret=$?
    if [ $ret != 0 ]; then
        echo "ERROR: Could not stop and remove all containers"
        exit $ret
    fi

    echo "Remove all other volumes"
    eval "docker volume ls -q -f dangling=true | xargs -L1 docker volume rm"
    ret=$?
    if [ $ret != 0 ]; then
        echo "ERROR: Could not remove dangling volumes"
        exit $ret
    fi

fi
##### /Everything ####

destroy_dangling_images() {
    echo "Remove dangling images"
    eval "docker images -a --filter=dangling=true -q | xargs -L1 docker rmi"
    ret=$?
    if [ $ret != 0 ]; then
        echo "ERROR: Could not remove dangling images"
        return $ret
    fi

    return 0
}

destroy_dangling_networks() {
    echo "Remove dangling networks"
    eval "docker network prune -f"
    ret=$?
    if [ $ret != 0 ]; then
        echo "ERROR: Could not remove dangling networks"
        return $ret
    fi

    return 0
}

ret=0

##### Dangling Images ####
if [ "${destroy_images}" == "true" ] || [ "${destroy_all}" == "true" ]; then
    destroy_dangling_images
    ret=$?
fi
##### /Dangling Images ####

##### Dangling Networks ####
if [ "${destroy_networks}" == "true" ] || [ "${destroy_all}" == "true" ]; then
    destroy_dangling_networks
    ret=$?
fi
##### /Dangling Networks ####

if [ "${destroy_all}" == "true" ]; then
    exit $ret
fi

#### Only for a Specific Environment ###
if [ -z "${env}" ]; then
    usage "ERROR: required: --environment"
    exit 1
fi

echo "Stop ${env} containers"
eval "docker ps -a --filter=name=${env} -q | xargs -L1 docker stop"
ret =$?
if [ $ret != 0 ]; then
    echo "ERROR: Could not stop ${env} containers"
    exit $ret
fi

echo "Remove ${env} containers"
if [ "${destroy_volumes}" == "true" ]; then
    echo "Remove ${env} volumes"
    destroy_volumes="-v"
fi

eval "docker ps -a -q --filter=name=${env} | xargs -L1 docker rm -f ${destroy_volumes}"
ret=$?
if [ $ret != 0 ]; then
    echo "ERROR: Could not remove ${env} containers"
    if [ "${destroy_volumes}" == "-v" ]; then
        echo "ERROR: and their volumes"
    fi
    exit $ret
fi

exit 0
#### /Only for a Specific Environment ###
