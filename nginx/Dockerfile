FROM nginx:mainline
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

### generate self-signed certificate (if they don't exist)
### default files (will be overwritten by gencerts.sh)

RUN apt-get update && apt-get -y install openssl

ENV CERT_DIR /etc/nginx/certs

COPY ./certs/ $CERT_DIR/

ENV APPLICATION_NAME default
ENV APP_KEY $CERT_DIR/key.pem
ENV APP_CERT $CERT_DIR/server.crt
ENV APP_CA $CERT_DIR/ca.pem

COPY ./scripts/gencerts.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

### template files
COPY ./templates/default.conf /etc/nginx/conf.d/

ENTRYPOINT ["./docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
