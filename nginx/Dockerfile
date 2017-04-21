FROM nginx:mainline
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# install openssl
RUN apt-get update && apt-get install openssl

# generate self-signed certificate (if they don't exist)
ENV CERT_DIR /etc/nginx/certs

COPY server.crt $CERT_DIR/
COPY key.pem $CERT_DIR/
COPY ca.pem $CERT_DIR/

ENV APPLICATION_NAME default
ENV APP_KEY $CERT_DIR/key.pem
ENV APP_CERT $CERT_DIR/server.crt
ENV APP_CA $CERT_DIR/ca.pem

COPY gencerts.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

# default configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# TODO: nginx conf generation.
# Used in conjunction with jwilder/docker-gen:latest
# templates
COPY ./templates /etc/nginx/templates

ENTRYPOINT ["./docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
