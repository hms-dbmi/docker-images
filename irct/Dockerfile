###########################
# build PIC-SURE war
###########################

FROM maven:3.5.4-jdk-8-alpine AS builder

ARG version

ENV GIT_REPO https://github.com/hms-dbmi/IRCT.git
ENV VERSION ${version:-master}

RUN apk update && DEPENDENCIES="git" \
    && apk --no-cache add $DEPENDENCIES \
    && git clone $GIT_REPO -b ${VERSION} irct \
    && cd irct \
    && mvn package \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/


###########################
# PIC-SURE Production
#########################

FROM jboss/wildfly:10.1.0.Final AS production

# TODO: It'd be nice if wildfly used alpine -Andre

LABEL maintainer="avillach_lab_developers@googlegroups.com"

# mysql database
ENV IRCT_DB_HOST localhost
ENV IRCT_DB_PORT 3306
ENV IRCT_DB_CONNECTION_USER root
ENV IRCT_DB_PASSWORD password

# JWT Token
ENV AUTH0_DOMAIN domain
ENV CLIENT_ID dummyid
ENV CLIENT_SECRET dummysecret
ENV IRCT_USER_FIELD email

# verification / introspection
ENV VERIFY_USER_METHOD sessionFilter
ENV TOKEN_INTROSPECTION_URL http://localhost
ENV TOKEN_INTROSPECTION_TOKEN dummytoken

ENV IRCT_KEY_TIMEOUT_IN_MINUTES 720
ENV WHITELIST_ENABLED false
ENV WHITELIST_CONFIG_FILE /whitelist/whitelist.json

# copy modules
# NOTE: wildfly-9.0.1.Final is a hard-coded assumption in maven build - Andre
COPY --from=builder irct/IRCT-CL/wildfly-9.0.1.Final/modules/system/layers/base/com/sql/mysql/main/* /modules/

# PIC-SURE event UMLS Synonym uses Oracle jdbc driver
# see https://github.com/hms-dbmi/PIC-SURE-resources
COPY --from=builder irct/IRCT-CL/wildfly-9.0.1.Final/modules/system/layers/base/com/oracle/main/* /modules/

# Copy whitelist.json
COPY --from=builder irct/IRCT-API/src/main/resources/whitelist.json.sample $WHITELIST_CONFIG_FILE

# Copy standalone.xml
COPY --from=builder irct/IRCT-CL/src/main/resources/wildfly-configuration/standalone.xml wildfly/standalone/configuration/

# Copy war file
COPY --from=builder irct/IRCT-CL/target/IRCT-CL.war wildfly/standalone/deployments/

# root required to create default scratch directory - Andre
USER root

# install modules
RUN wildfly/bin/jboss-cli.sh --command="module add --name=com.sql.mysql \
    --resources=/modules/mysql-connector-java-5.1.38.jar --dependencies=javax.api" \
    && wildfly/bin/jboss-cli.sh --command="module add --name=com.oracle \
    --resources=/modules/ojdbc6-11.2.0.3.jar --dependencies=javax.api,javax.transaction.api" \
    #
    # IRCT scratch directory
    && mkdir -p /scratch/irct \
    && chmod a+rw /scratch/irct \
    # make whitelist accessible to jboss
    && chmod a+rw $WHITELIST_CONFIG_FILE

USER jboss

ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
