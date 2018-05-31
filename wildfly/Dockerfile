FROM dbmi/wildfly-base-jdk:9

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 12.0.0.Final
ENV WILDFLY_SHA1 b2039cc4979c7e50a0b6ee0e5153d13d537d492f
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# wildfly 12.0.0.Final using jandex-2.0.4.Final which has a bug needs to be replaced by 2.0.5
# but wildfly 13 is coming on May 31th, 2018
COPY jandex-2.0.5.Final.jar $JBOSS_HOME/modules/system/layers/base/org/jboss/jandex/main
RUN rm $JBOSS_HOME/modules/system/layers/base/org/jboss/jandex/main/jandex-2.0.4.Final.jar \
    && sed -i 's/2.0.4/2.0.5/g' $JBOSS_HOME/modules/system/layers/base/org/jboss/jandex/main/module.xml

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
