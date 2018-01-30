FROM dbmi/transmart-data:release-16.2 AS transmart-data

### Build Transmart Configurations ###
FROM alpine:3.6 AS install_config

COPY --from=transmart-data /transmart-data/ /transmart-data/

RUN DEPENDENCIES=" \
    make \
    php5" \
    && apk upgrade \
    && apk --no-cache --update add $DEPENDENCIES bash \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && ln -s /usr/bin/php5 /usr/bin/php \
    && cd /transmart-data \
    && source ./vars \
    && make -C config install \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/


### Transmart Production ###
FROM tomcat:7.0-alpine
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

COPY --from=install_config /root/.grails/transmartConfig/*.groovy /root/.grails/transmartConfig/

#ENV ORACLEHOST localhost
#ENV DB_USER biomart_user
#ENV BIOMART_USER demouser
#ENV DB_PORT 1521
#ENV OAUTH true
#ENV SAML false
#ENV GWAVA false

ENV TRANSMART_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/transmart.war

ENV CATALINA_OPTS "$CATALINA_OPTS -Xms512m -Xmx2g -Djava.awt.headless=true -XX:+UseConcMarkSweepGC"

RUN apk upgrade \
    && apk --no-cache --update add curl bash \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && curl $TRANSMART_WAR_URL > $CATALINA_HOME/webapps/transmart.war \
    && apk del curl && rm -rf /var/cache/apk/


ENTRYPOINT ["./bin/catalina.sh", "run"]
