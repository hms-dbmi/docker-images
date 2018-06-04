#!/bin/bash
set -u

VIRTUAL_HOST=${1:-default}
CERT_CA=${2:-ca.pem}

# if we are not bind mounting in certs or the user has not already generated certs
# create self-signed certs
echo "Verify (if existing) certificates"
echo

openssl verify -CAfile $CERT_DIR/$CERT_CA $CERT_DIR/$VIRTUAL_HOST.crt 2>/tmp/err
openssl rsa -check -noout -in $CERT_DIR/$VIRTUAL_HOST.key 2>>/tmp/err

if [ -s /tmp/err ]; then

	# Generate CA private key
	openssl genrsa -out $CERT_DIR/${CERT_CA%.*}.key 2048
	openssl rsa -in $CERT_DIR/${CERT_CA%.*}.key -out $CERT_DIR/${CERT_CA%.*}.key
	# Generate CA
	openssl req -new -x509 -days 365 -key $CERT_DIR/${CERT_CA%.*}.key -sha256 -subj "/C=US/ST=California/L=Everywhere/CN=$VIRTUAL_HOST" -out $CERT_DIR/$CERT_CA

	# Generate domain private key
	openssl genrsa -out $CERT_DIR/$VIRTUAL_HOST.key 2048
	# Remove password from private key
	openssl rsa -in $CERT_DIR/$VIRTUAL_HOST.key -out $CERT_DIR/$VIRTUAL_HOST.key

	# Generate CSR (make sure the common name CN field matches your server
	# address. It's set to "RO_COMMONNAME" environment variable here.)
	openssl req -new -key $CERT_DIR/$VIRTUAL_HOST.key -out $CERT_DIR/$VIRTUAL_HOST.csr -subj "/C=US/ST=California/L=Everywhere/CN=$VIRTUAL_HOST"
	# Sign the CSR and create certificate
	openssl x509 -req -days 365 -in $CERT_DIR/$VIRTUAL_HOST.csr -CA $CERT_DIR/$CERT_CA -CAkey $CERT_DIR/${CERT_CA%.*}.key -CAcreateserial -signkey $CERT_DIR/$VIRTUAL_HOST.key -out $CERT_DIR/$VIRTUAL_HOST.crt

	# Clean up
	rm $CERT_DIR/$VIRTUAL_HOST.csr
	rm $CERT_DIR/${CERT_CA%.*}.key
	rm $CERT_DIR/${CERT_CA%.*}.srl
	chmod 600 $CERT_DIR/$VIRTUAL_HOST.crt $CERT_DIR/$VIRTUAL_HOST.key $CERT_DIR/$CERT_CA

	cp $CERT_DIR/$CERT_CA /usr/local/share/ca-certificates/
	update-ca-certificates

    rm /tmp/err

	echo
	echo "Generated default certificates for $VIRTUAL_HOST"
	echo
fi

# allows for nginx to stay up even if services are down
# see default.conf - Andre
#export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`

#echo "Nameserver is: $NAMESERVER"

#sed -s -i "s/\$NAMESERVER/$NAMESERVER/g" /etc/nginx/conf.d/*

#echo "Running $@"
#exec "$@"
