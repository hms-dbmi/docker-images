FROM nginx:alpine
LABEL maintainer="andre_rosa@hms.harvard.edu"

RUN apk update \
    && apk upgrade \
    && apk add --update openssl ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /etc/nginx

ENV APPLICATION_NAME default

ENV CERT_DIR /etc/nginx/certs

ENV APP_KEY $CERT_DIR/key.pem
ENV APP_CERT $CERT_DIR/server.crt
ENV APP_CA $CERT_DIR/ca.pem

# generate self-signed certificate (if they don't exist)
# default files (will be overwritten by init.sh)
COPY ./certs/ $CERT_DIR/
COPY ./scripts/init.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

### template files
COPY ./templates/default.conf /etc/nginx/conf.d/

ENTRYPOINT ["/docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
