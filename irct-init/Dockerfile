###########################
# PIC-SURE init Production
#########################
FROM alpine:3.7 AS production

# dockerfile author
LABEL maintainer="andre_rosa@hms.harvard.edu"

ARG version

ENV GIT_REPO https://github.com/hms-dbmi/PIC-SURE-resources.git
ENV VERSION ${version:-master}
ENV IRCT_INIT_HOME /scratch/irct/sql

WORKDIR $IRCT_INIT_HOME

# NOTE: $IRCT_INIT_HOME/sql/init-db.sh will be replaced by small golang-alpine dynamic program (eventually) -Andre
# scripts will run at startup to populate the DB

RUN apk upgrade \
    && DEPENDENCIES="git" \
    && apk --no-cache --update add $DEPENDENCIES bash mysql-client \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    #
    # get available resources
    && git clone $GIT_REPO -b ${VERSION} $IRCT_INIT_HOME \
    #
    # clean up
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/

# mysql database
ENV IRCT_DB_HOST localhost
ENV IRCT_DB_CONNECTION_USER root
ENV IRCT_DB_PASSWORD password

# must use shell form; docker does not parse env variables for ENTRYPOINT[] or CMD[]
ENTRYPOINT ["./install.sh"]
CMD ["--help"]
