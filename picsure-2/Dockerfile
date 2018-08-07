###########################
# build PIC-SURE war
###########################

FROM maven:3.5.4-jdk-9-slim AS builder

ARG version
ARG username
ARG psw

ENV GIT_REPO github.com/hms-dbmi/pic-sure.git
ENV VERSION ${version:-master}
ENV USERNAME ${username}
ENV PASSWORD :${psw}@

RUN  apt-get update && DEPENDENCIES="git" \
    && apt-get install -y $DEPENDENCIES \
    && export HISTCONTROL=ignorespace \
    && git clone https://$USERNAME$PASSWORD$GIT_REPO -b ${VERSION} picsure \
    && cd picsure \
    && mvn package -Dmaven.test.skip=true \
    && apt-get remove -y $DEPENDENCIES && rm -rf /var/cache/apk/


###########################
# PIC-SURE Production
#########################

FROM dbmi/wildfly:13 AS production

ARG projects
ENV PROJECTS ${projects:-pic-sure-api-war}

# TODO: It'd be nice if wildfly used alpine -Andre

LABEL maintainer="avillach_lab_developers@googlegroups.com"

# mysql database
ENV PICSURE2_DB_CONNECTION_USER root
ENV PICSURE2_MYSQLADDRESS localhost
ENV PICSURE2_DB_PORT 3306
ENV PICSURE2_MYSQLPASS password

# JWT Token
ENV CLIENT_ID dummyid
ENV CLIENT_SECRET dummysecret
ENV picsure_USER_FIELD sub

# copy modules
COPY --from=builder picsure/pic-sure-api-war/target/modules/system/layers/base/com/sql/mysql/main/* /modules/

# Copy standalone.xml
COPY --from=builder picsure/pic-sure-api-war/src/main/resources/wildfly-configuration/standalone.xml wildfly/standalone/configuration/

# Copy war file
COPY --from=builder ${projects} wildfly/standalone/deployments/

# root required to create default scratch directory - Andre
USER root

# install modules
RUN wildfly/bin/jboss-cli.sh --command="module add --name=com.sql.mysql \
    --resources=/modules/mysql-connector-java-5.1.38.jar --dependencies=javax.api"

USER jboss

ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
