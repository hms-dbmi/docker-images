#!/bin/bash
set -e

# Generate dhparam file if required
# Note: if $DHPARAM_BITS is not defined, generate-dhparam.sh will use 2048 as a default
/app/generate-dhparam.sh $DHPARAM_BITS

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
export RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g')
if [ "x$RESOLVERS" = "x" ]; then
    echo "Warning: unable to determine DNS resolvers for nginx" >&2
    unset RESOLVERS
fi

echo "Nameserver is: $RESOLVERS"
echo

sed -i "s/{{ \$\.Env\.RESOLVERS }}/$RESOLVERS/g" /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/nginx.tmpl

/app/generate-certs.sh $VIRTUAL_HOST $CERT_CA

echo "Running $@"
exec "$@"
