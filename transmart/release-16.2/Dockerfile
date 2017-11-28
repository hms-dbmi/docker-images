FROM tomcat:8.0.36
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TRANSMART_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/transmart.war
ENV TRANSMART_GWAVA_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/gwava.war

RUN curl $TRANSMART_WAR_URL > $CATALINA_HOME/webapps/transmart.war  \
    && curl $TRANSMART_GWAVA_WAR_URL > $CATALINA_HOME/webapps/gwava.war

ENV ORACLEHOST localhost
ENV DB_USER biomart_user
ENV BIOMART_USER demouser
ENV DB_PORT 1521
ENV AUTH0_DOMAIN domain
ENV AUTH0_CLIENT_ID client_id
ENV AUTH0_CLIENT_SECRET client_secret

# use bash instead of sh. easier for container debugging
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Remove garbage
RUN rm -rf /usr/local/tomcat/webapps/examples
RUN rm -rf /usr/local/tomcat/webapps/docs

ENV CATALINA_OPTS "$CATALINA_OPTS -Xms512m -Xmx2g -Djava.awt.headless=true -XX:+UseConcMarkSweepGC"

RUN mkdir -p /root/.grails/transmartConfig \
    && ln -s /root/.grails/ .grails

COPY BuildConfig.groovy /root/.grails/transmartConfig
COPY DataSource.groovy /root/.grails/transmartConfig
COPY Config.groovy /root/.grails/transmartConfig
COPY RModulesConfig.groovy /root/.grails/transmartConfig

# With nginx as our front-end, make sure scheme protocol and IP is forwarded to tomcat - AR
COPY server.xml $CATALINA_HOME/conf/

# install war files
ENV TRANSMART_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/transmart.war
ENV TRANSMART_GWAVA_WAR_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/gwava.war

RUN curl $TRANSMART_WAR_URL > $CATALINA_HOME/webapps/transmart.war  \
    && curl $TRANSMART_GWAVA_WAR_URL > $CATALINA_HOME/webapps/gwava.war

ENTRYPOINT ["./bin/catalina.sh", "run"]
