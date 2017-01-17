FROM mysql:latest
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# set default variables
ENV IRCT_RESOURCE_NAME demo
ENV IRCT_DB_CONNECTION_HOST localhost
ENV IRCT_DB_CONNECTION_USER root
ENV IRCT_DB_CONNECTION_PASSWORD my-secret-pw
ENV IRCT_AUTH0_DOMAIN domain
ENV IRCT_AUTH0_CLIENT_ID client_id

# scripts will run at startup to populate the DB
COPY init-db/i2b2tranSMARTsetup.sql /scratch/irct/sql/
COPY init-db/Monitoring.sql /scratch/irct/sql/
COPY init-db/ResultDataConverters.sql /scratch/irct/sql/
COPY init-db/init-db.sh /scratch/irct/sql/

# must use shell form; docker does not parse env variables for ENTRYPOINT[] or CMD[]
ENTRYPOINT ./scratch/irct/sql/init-db.sh \
  -h $IRCT_DB_CONNECTION_HOST \
  -u $IRCT_DB_CONNECTION_USER \
  -p $IRCT_DB_CONNECTION_PASSWORD \
  -d irct
