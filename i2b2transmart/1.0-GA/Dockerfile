FROM tomcat:8.0.36
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TOMCAT_VERSION 8.0.36

# database variables
ENV ORACLEHOST localhost
ENV DB_USER biomart_user
ENV BIOMART_USER demouser
ENV DB_PORT 1521
ENV DB_DB ORCLPDB1

# i2b2-wildlfy host
ENV I2B2_WILDFLY_HOST localhost

# auth0 variables
ENV AUTH0_DOMAIN domain
ENV AUTH0_CLIENT_ID client_id
ENV AUTH0_CLIENT_SECRET client_secret

# use bash instead of sh. easier for container debugging
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Remove garbage
RUN rm -rf /usr/local/tomcat/webapps/examples
RUN rm -rf /usr/local/tomcat/webapps/docs

ENV CATALINA_OPTS "$CATALINA_OPTS -Xms512m -Xmx2g -Djava.awt.headless=true -XX:+UseConcMarkSweepGC"

RUN mkdir -p /root/.grails/transmartConfig

COPY BuildConfig.groovy /root/.grails/transmartConfig
COPY DataSource.groovy /root/.grails/transmartConfig
COPY Config.groovy /root/.grails/transmartConfig
COPY RModulesConfig.groovy /root/.grails/transmartConfig

# With nginx as our front-end, make sure scheme protocol and IP is forwarded to tomcat - Andre
COPY server.xml $CATALINA_HOME/conf/

COPY target/transmart.war $CATALINA_HOME/webapps/

ENTRYPOINT ["./bin/catalina.sh", "run"]
