#!/bin/sh
set -u

# if we are not bind mounting in certs or the user has not already generated certs
# create self-signed certs
echo "Verify (if existing) certificates"

openssl verify -CAfile $APP_CA $APP_CERT 2>/tmp/err
openssl rsa -check -noout -in $APP_KEY 2>>/tmp/err

if [ -s /tmp/err ]; then

	# Generate private key
	openssl genrsa -out $APP_KEY 2048
	# Remove password from private key
	openssl rsa -in $APP_KEY -out $APP_KEY
	# Generate CSR (make sure the common name CN field matches your server
	# address. It's set to "RO_COMMONNAME" environment variable here.)
	openssl req -new -key $APP_KEY -out $CERT_DIR/server.csr -subj "/C=US/ST=California/L=Everywhere/CN=$APPLICATION_NAME"
	# Sign the CSR and create certificate
	openssl x509 -req -days 365 -in $CERT_DIR/server.csr -signkey $APP_KEY -out $APP_CERT

	# Clean up
	rm $CERT_DIR/server.csr
	chmod 600 $APP_CERT $APP_KEY
    rm /tmp/err

	echo
	echo "Generated default certificates for $APPLICATION_NAME at $APP_CERT and $APP_KEY"
	echo
fi

echo "Running $@"
exec "$@"
