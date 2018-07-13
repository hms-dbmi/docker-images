FROM i2b2/i2b2-wildfly:release-v1.7.09c.0001 AS production
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ARG db_type

# database connection
ENV DB_HOST localhost
ENV DB_PORT 1521
ENV DB_DB ORCL

ENV I2B2HIVE demouser
ENV I2B2DEMODATA demouser
ENV I2B2METADATA demouser
ENV I2B2PM demouser
ENV I2B2WORKDATA demouser

## picsure-36, i2b2tm-34 (resolve OOM errors) - Andre
JAVA_OPTS "$JAVA_OPTS Xms512m -Xmx1024m -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true

# moved datasource usernames & passwords to standalone.xml.
# standalone.xml allows for env variable interpolation.
# datasources do not
RUN rm /opt/jboss/wildfly/standalone/deployments/crc-ds.xml \
    && rm /opt/jboss/wildfly/standalone/deployments/ont-ds.xml \
    && rm /opt/jboss/wildfly/standalone/deployments/pm-ds.xml \
    && rm /opt/jboss/wildfly/standalone/deployments/work-ds.xml

COPY crc.properties /opt/jboss/wildfly/standalone/configuration/crcapp/
COPY ontology.properties /opt/jboss/wildfly/standalone/configuration/ontologyapp/
COPY standalone-${db_type:-oracle}.xml /opt/jboss/wildfly/standalone/configuration/standalone.xml

# do not use bin/prescript.sh
# uses default passwords only. not usable in production environments - Andre
ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
