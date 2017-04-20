FROM mysql:latest
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# set default variables
ENV IRCT_RESOURCE_NAME demo
ENV IRCTMYSQLADDRESS localhost
ENV IRCT_DB_CONNECTION_USER root
ENV IRCTMYSQLPASS my-secret-pw
ENV AUTH0_DOMAIN domain
ENV AUTH0_CLIENT_ID client_id

# scripts will run at startup to populate the DB
COPY init-db/i2b2tranSMARTsetup.sql /scratch/irct/sql/
COPY init-db/Monitoring.sql /scratch/irct/sql/
COPY init-db/ResultDataConverters.sql /scratch/irct/sql/
COPY init-db/AWS-S3.sql /scratch/irct/sql/
COPY init-db/init-db.sh /scratch/irct/sql/

# must use shell form; docker does not parse env variables for ENTRYPOINT[] or CMD[]
ENTRYPOINT ./scratch/irct/sql/init-db.sh -d irct
