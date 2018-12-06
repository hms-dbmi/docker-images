FROM jboss/base:latest

# User root user to install software
USER root

RUN yum -y install which && yum install -y zip && yum clean all

# Switch back to jboss user
USER jboss

# Install necessary packages
RUN curl -s "https://get.sdkman.io" | bash \
    && source "$HOME/.sdkman/bin/sdkman-init.sh" \ 
    && sdk version \
    && sdk list java \
    && sdk i java 9.0.4-open \
    && java -version \
    && which java

#RUN ln -s /root/.sdkman/candidates/java/current/bin/java /usr/bin/java
#RUN ls -al /usr/bin/
#RUN which java; java -version
#RUN ls -al /root/.sdkman/candidates/java/current

ENV JAVA_HOME=/opt/jboss/.sdkman/candidates/java/current/
ENV PATH="$JAVA_HOME/bin:$PATH"
