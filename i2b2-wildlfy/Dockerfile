FROM i2b2/i2b2-wildfly:0.1
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# database connection
ENV DB_HOST localhost
ENV DB_PORT 1521

# crc-ds.xml
ENV CRC_BOOTSTRAP_PASSWORD demouser
ENV CRC_DEMO_PASSWORD demouser

# ont-ds.xml
ENV ONT_DEMO_PASSWORD demouser
ENV ONT_BOOTSTRAP_PASSWORD demouser

# pm-ds.xml
ENV PM_BOOTSTRAP_PASSWORD demouser

# work-ds.xml
ENV WORK_BOOTSTRAP_PASSWORD demouser
ENV WORK_DEMO_PASSWORD demouser

COPY crc.properties /opt/jboss/wildfly/standalone/configuration/crcapp/
COPY ontology.properties /opt/jboss/wildfly/standalone/configuration/ontologyapp/
COPY standalone.xml /opt/jboss/wildfly/standalone/configuration/

# contains username/password to DB users
#COPY crc-ds.xml /opt/jboss/wildfly/standalone/deployments/
#COPY ont-ds.xml /opt/jboss/wildfly/standalone/deployments/
#COPY pm-ds.xml /opt/jboss/wildfly/standalone/deployments/
#COPY work-ds.xml /opt/jboss/wildfly/standalone/deployments/

# moved datasource usernames & paswords to standalone.xml.
# standalone.xml allows for env variable interpolation.
# datasources do not`
RUN rm /opt/jboss/wildfly/standalone/deployments/crc-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/ont-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/pm-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/work-ds.xml
