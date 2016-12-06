FROM jboss/wildfly
MAINTAINER Jeremy R. Easton-Marks <Jeremy_Easton-Marks@hms.harvard.edu>

# Add WAR FIle
ADD IRCT-CL.war /opt/jboss/wildfly/standalone/deployments/

# Add standalone.xml
ADD standalone.xml /opt/jboss/wildfly/standalone/configuration/

# Add MySQL Module
ADD mySQL/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/
ADD mySQL/mysql-connector-java-5.1.22.jar /opt/jboss/wildfly/modules/system/layers/base/com/sql/mysql/main/

# Add Oracle Module
ADD oracle/module.xml /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/
ADD oracle/ojdbc6.jar /opt/jboss/wildfly/modules/system/layers/base/com/oracle/main/

USER root
# IRCT Scratch Directory
RUN mkdir /scratch
RUN mkdir /scratch/irct


# SET DEFAULT ENV VARIABLEs

IRCT_DB_CONNECTION_URL=mysql:3306/irct
IRCT_DB_CONNECTION_USER=root
IRCT_DB_CONNECTION_PASSWORD=password
IRCT_AUTH0_DOMAIN=domain
IRCT_AUTH0_CLIENT_ID=client_id
IRCT_AUTH0_CLIENT_SECRET=client_secret
IRCT_USER_FIELD=email
IRCT_KEY_TIMEOUT_IN_MINUTES=720
IRCT_DB_ADDRESS=localhost:3306/irct
IRCT_DB_PASSWORD=root
