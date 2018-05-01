#!/bin/sh
set -u

# if we are not bind mounting in certs or the user has not already generated certs
# create self-signed certs
echo "Verify (if existing) certificates"
echo

openssl verify -CAfile $APP_CA $APP_CERT 2>/tmp/err
openssl rsa -check -noout -in $APP_KEY 2>>/tmp/err

if [ -s /tmp/err ]; then

	# Generate CA private key
	openssl genrsa -out $CERT_DIR/ca.key 2048
	openssl rsa -in $CERT_DIR/ca.key -out $CERT_DIR/ca.key
	# Generate CA
	openssl req -new -x509 -days 365 -key $CERT_DIR/ca.key -sha256 -subj "/C=US/ST=California/L=Everywhere/CN=$APPLICATION_NAME" -out $APP_CA

	# Generate domain private key
	openssl genrsa -out $APP_KEY 2048
	# Remove password from private key
	openssl rsa -in $APP_KEY -out $APP_KEY

	# Generate CSR (make sure the common name CN field matches your server
	# address. It's set to "RO_COMMONNAME" environment variable here.)
	openssl req -new -key $APP_KEY -out $CERT_DIR/server.csr -subj "/C=US/ST=California/L=Everywhere/CN=$APPLICATION_NAME"
	# Sign the CSR and create certificate
	openssl x509 -req -days 365 -in $CERT_DIR/server.csr -CA $APP_CA -CAkey $CERT_DIR/ca.key -CAcreateserial -signkey $APP_KEY -out $APP_CERT

	# Clean up
	rm $CERT_DIR/server.csr
	rm $CERT_DIR/ca.key
	rm $CERT_DIR/ca.srl
	chmod 600 $APP_CERT $APP_KEY $APP_CA

	cp $APP_CERT /usr/local/share/ca-certificates/
	update-ca-certificates

    rm /tmp/err

	echo
	echo "Generated default certificates for $APPLICATION_NAME at $APP_CERT and $APP_KEY"
	echo
fi

# allows for nginx to stay up even if services are down
# see default.conf - Andre
export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`

echo "Nameserver is: $NAMESERVER"
echo

sed -i "s/\$NAMESERVER/$NAMESERVER/g" /etc/nginx/conf.d/default.conf

echo "Running $@"
exec "$@"
