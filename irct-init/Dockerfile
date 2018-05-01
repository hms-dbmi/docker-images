FROM alpine:3.7 AS production

# NOTE: All going away. Will be replaced by small golang-alpine dynamic program -Andre

# dockerfile author
LABEL maintainer="andre_rosa@hms.harvard.edu"

RUN apk upgrade \
    && apk --no-cache --update add bash mysql-client \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/

# set default variables
ENV IRCT_RESOURCE_NAME demo
ENV IRCTMYSQLADDRESS localhost
ENV IRCT_DB_CONNECTION_USER root
ENV IRCTMYSQLPASS my-secret-pw
ENV AUTH0_DOMAIN domain
ENV CLIENT_ID client_id
ENV TRANSMART_RESOURCE https://transmart:8080

# sci db service introduced in IRCT build 2493.hackathon
ENV SCIDB_HOST http://scidb:8080
ENV SCIDB_USER scidbuser
ENV SCIDB_PASSWORD scidbpassword

# scripts will run at startup to populate the DB
COPY init-db/ /scratch/irct/sql/

# must use shell form; docker does not parse env variables for ENTRYPOINT[] or CMD[]
ENTRYPOINT ["./scratch/irct/sql/init-db.sh", "-d", "irct"]
