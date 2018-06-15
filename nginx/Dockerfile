FROM nginx:alpine AS production
LABEL maintainer="andre_rosa@hms.harvard.edu"

RUN apk upgrade \
    && apk add --update --no-cache bash openssl ca-certificates \
    && update-ca-certificates \
    && sed -i 's/worker_processes.*$/worker_processes auto;/g' /etc/nginx/nginx.conf \
    && mkdir -p /etc/nginx/dhparam/ \
    && rm -rf /var/cache/apk/*

WORKDIR /etc/nginx


### conf and template files
ENV VIRTUAL_HOST default
COPY ./templates/ /etc/nginx/conf.d


### certificates
# self-signed default certificates (/app/generate-certs.sh)
ENV CERT_DIR /etc/nginx/certs
COPY ./certs/ $CERT_DIR/

COPY ./scripts/ /app/

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
