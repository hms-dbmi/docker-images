### PIC-SURE Init Production ###
FROM alpine:3.7 AS production

# dockerfile author
LABEL maintainer="andre_rosa@hms.harvard.edu"

ARG artifact
ARG artifact_url
ARG artifact_version

ENV ARTIFACT ${artifact:-PIC-SURE-resources}
ENV ARTIFACT_URL ${artifact_url:-https://github.com/hms-dbmi/${ARTIFACT}/archive}
ENV ARTIFACT_VERSION ${artifact_version:-1.4.2}

ENV IRCT_INIT_HOME /scratch/irct
WORKDIR $IRCT_INIT_HOME

# NOTE: $IRCT_INIT_HOME/sql/init-db.sh will be replaced by small golang-alpine dynamic program (eventually) -Andre
# scripts will run at startup to populate the DB

RUN apk upgrade \
    && DEPENDENCIES="unzip curl" \
    && apk --no-cache --update add $DEPENDENCIES bash mysql-client \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    #
    # get available resources
    #
    && curl -L ${ARTIFACT_URL}/${ARTIFACT_VERSION}.zip -o ${ARTIFACT}-${ARTIFACT_VERSION}.zip \
    && unzip ${ARTIFACT}-${ARTIFACT_VERSION}.zip \
    && mv ${ARTIFACT}-${ARTIFACT_VERSION} $IRCT_INIT_HOME/sql \
    && ls -alr $IRCT_INIT_HOME/sql \
    #
    # clean up
    && rm -rf ${ARTIFACT}-${ARTIFACT_VERSION}* \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/

# set default variables
ENV IRCTMYSQLADDRESS localhost
ENV IRCT_DB_CONNECTION_USER root
ENV IRCTMYSQLPASS my-secret-pw



# must use shell form; docker does not parse env variables for ENTRYPOINT[] or CMD[]
ENTRYPOINT ["./sql/install.sh"]
CMD ["--help"]
