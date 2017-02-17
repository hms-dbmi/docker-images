FROM tomcat:8.0.36
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TOMCAT_VERSION 8.0.36

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

ENV CATALINA_OPTS "-Xms768m -Xmx1024m -XX:MaxPermSize=512m"

RUN mkdir -p /root/.grails/transmartConfig

COPY BuildConfig.groovy /root/.grails/transmartConfig
COPY DataSource.groovy /root/.grails/transmartConfig
COPY Config.groovy /root/.grails/transmartConfig
COPY RModulesConfig.groovy /root/.grails/transmartConfig

COPY transmart.war /usr/local/tomcat/webapps/

ENTRYPOINT ["./bin/catalina.sh", "run"]
