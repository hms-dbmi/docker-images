FROM dbmi/wildfly:12 AS production

# SET DEFAULT ENV VARIABLES
ENV PICSURE2_DB_CONNECTION_USER root
ENV PICSURE2_MYSQLADDRESS localhost
ENV PICSURE2_DB_PORT 3306
ENV PICSURE2_MYSQLPASS password
ENV AUTH0_DOMAIN domain
ENV CLIENT_ID cliend_id
ENV CLIENT_SECRET secret
ENV PICSURE2_USER_ID_CLAIM email

# Copy standalone.xml
COPY standalone.xml /opt/jboss/wildfly/standalone/configuration/

# Copy MySQL Module
COPY mySQL/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/
COPY mySQL/mysql-connector-java-5.1.22.jar /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/

# Copy Oracle Module
COPY oracle/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/
# LICENSE!!!!! (Used for UMLS synonyms)
#COPY oracle/ojdbc6.jar /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/

USER root

# COPY WAR FIle
COPY target/pic-sure-api-2.war /opt/jboss/wildfly/standalone/deployments/

ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]

### PIC-SURE Production with Secrets Management
FROM dbmi/secret-getter:0.9-alpha AS executable
FROM dbmi/secret-getter:0.9-runtime AS secure
