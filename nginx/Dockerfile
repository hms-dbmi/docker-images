FROM nginx:mainline
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

COPY nginx.conf /etc/nginx/

# install openssl
RUN apt-get update && apt-get install openssl

# generate self-signed certificate (if they don't exist)
ENV CERT_DIR /etc/nginx/certs

COPY server.crt $CERT_DIR/
COPY key.pem $CERT_DIR/

ENV APPLICATION_NAME default
ENV APP_KEY $CERT_DIR/key.pem
ENV APP_CERT $CERT_DIR/server.crt

COPY gencerts.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

ENTRYPOINT ["./docker-entrypoint"]
CMD ["nginx", "-g", "daemon off;"]
