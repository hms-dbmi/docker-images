FROM jboss/wildfly
MAINTAINER Jeremy R. Easton-Marks <Jeremy_Easton-Marks@hms.harvard.edu>

# SET DEFAULT ENV VARIABLES
ENV IRCT_DB_CONNECTION_USER root
ENV IRCTMYSQLADDRESS localhost
ENV IRCT_DB_PORT 3306
ENV IRCTMYSQLPASS password
ENV AUTH0_DOMAIN domain
ENV AUTH0_CLIENT_ID client_id
ENV AUTH0_CLIENT_SECRET client_secret
ENV IRCT_USER_FIELD email
ENV IRCT_KEY_TIMEOUT_IN_MINUTES 720

# Copy standalone.xml
COPY standalone.xml /opt/jboss/wildfly/standalone/configuration/

# Copy MySQL Module
COPY mySQL/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/
COPY mySQL/mysql-connector-java-5.1.22.jar /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/

# Copy Oracle Module
COPY oracle/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/
COPY oracle/ojdbc6.jar /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/

USER root

# IRCT Scratch Directory
RUN mkdir -p /scratch/irct

# COPY WAR FIle
COPY target/IRCT-CL.war /opt/jboss/wildfly/standalone/deployments/

ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
