FROM i2b2/i2b2-wildfly:release-v1.7.09a.0002
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# database connection
ENV ORACLEHOST localhost
ENV ORACLEDB ORCL
ENV DB_PORT 1521

ENV I2B2HIVE demouser
ENV I2B2DEMODATA demouser
ENV I2B2METADATA demouser
ENV I2B2PM demouser
ENV I2B2WORKDATA demouser

# moved datasource usernames & passwords to standalone.xml.
# standalone.xml allows for env variable interpolation.
# datasources do not
RUN rm /opt/jboss/wildfly/standalone/deployments/crc-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/ont-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/pm-ds.xml
RUN rm /opt/jboss/wildfly/standalone/deployments/work-ds.xml

COPY crc.properties /opt/jboss/wildfly/standalone/configuration/crcapp/
COPY ontology.properties /opt/jboss/wildfly/standalone/configuration/ontologyapp/
COPY standalone.xml /opt/jboss/wildfly/standalone/configuration/
