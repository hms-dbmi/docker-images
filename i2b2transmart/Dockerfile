FROM tomcat:8.0.36
ENV TOMCAT_VERSION 8.0.36

RUN apt-get update && apt-get install -y wget

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Remove garbage
RUN rm -rf /usr/local/tomcat/webapps/examples
RUN rm -rf /usr/local/tomcat/webapps/docs
#RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Add admin/admin user
ADD tomcat-users.xml /usr/local/tomcat/conf/

# Update logging file
#RUN echo "org.apache.jasper.servlet.TldScanner.level = FINE" >> /usr/local/tomcat/conf/logging.properties
#RUN echo "org.apache.catalina.core.ContainerBase.[Catalina].level = INFO" >> /usr/local/tomcat/conf/logging.properties
#RUN echo "org.apache.catalina.core.ContainerBase.[Catalina].handlers = java.util.logging.ConsoleHandler" >> /usr/local/tomcat/conf/logging.properties

ENV CATALINA_OPTS "-Xms768m -Xmx1024m -XX:MaxPermSize=512m -Dport.http.nonssl=\${CATALINA_BASE_PORT}"
#EXPOSE 8090
#EXPOSE 8009

RUN mkdir /root/.grails
RUN mkdir /root/.grails/transmartConfig
COPY server.xml /usr/local/tomcat/conf
COPY BuildConfig.groovy /root/.grails/transmartConfig
COPY DataSource.groovy /root/.grails/transmartConfig
COPY Config.groovy /root/.grails/transmartConfig
COPY RModulesConfig.groovy /root/.grails/transmartConfig
COPY transmart.war /usr/local/tomcat/webapps/

ENTRYPOINT ["./bin/catalina.sh", "run"]
