FROM tomcat:7.0-alpine
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TRANSMART_GWAVA_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/gwava.war

RUN apk upgrade --update --no-cache \
    && apk --update --no-cache add curl \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && curl $TRANSMART_GWAVA_WAR_URL > $CATALINA_HOME/webapps/gwava.war \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["./bin/catalina.sh", "run"]
