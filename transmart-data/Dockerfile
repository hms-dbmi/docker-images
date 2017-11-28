FROM store/oracle/database-instantclient:12.2.0.1
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TRANSMART_DATA_NAME transmart-data-release-16.2
ENV TRANSMART_DATA_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/${TRANSMART_DATA_NAME}.zip
ENV PATH /root/.sdkman/candidates/groovy/current/bin:$PATH

# Set Java options (see stackoverflow.com/questions/15464963)
ENV JAVA_OPTS "-Duser.timezone=UTC -Djava.security.egd=file:///dev/urandom"

COPY grapeConfig.xml /root/.groovy/

RUN yum -y update && yum install -y bash curl make php unzip zip java-1.7.0-openjdk-devel which \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    #
    # Install groovy
    && export CYGWIN=winsymlinks:native \
    && curl -s https://get.sdkman.io | bash  && sleep 20 \
    && source /root/.sdkman/bin/sdkman-init.sh \
    && echo "sdkman_auto_answer=true" >> /root/.sdkman/etc/config \
    && sdk install groovy 2.4.5 \
    #
    # Install grape
    # Way too many times this fails to load during startup scripts. Just download it here.
    && grape install net.sf.opencsv opencsv 2.3 \
    #
    # get transmart-data
    && curl ${TRANSMART_DATA_URL} -o ${TRANSMART_DATA_NAME}.zip \
    && unzip ${TRANSMART_DATA_NAME}.zip \
    && rm -rf ${TRANSMART_DATA_NAME}.zip \
    && mv ${TRANSMART_DATA_NAME} transmart-data \
    && cd transmart-data && mv vars.sample vars \
    #
    # modify vars file
    && sed -i 's/^#ORACLE/ORACLE/g' vars \
    && sed -i 's/ORACLE_MANAGE_TABLESPACES\=0/ORACLE_MANAGE_TABLESPACES\=1/g' vars \
    && sed -i 's/^ORACLE_TABLESPACES_DIR\=.*$/ORACLE_TABLESPACES_DIR\=\/opt\/oracle\/oradata/g' vars \
    && sed -i 's/ORAHOST\=.*$/ORAHOST\=transmartdb/g' vars \
    && sed -i 's/ORASID\=.*$/ORASID\=ORCLCDB/g' vars \
    && sed -i 's/ORAUSER\=.*$/ORAUSER\=system/g' vars \
    && sed -i 's/ORAPASSWORD\=.*$/ORAPASSWORD\=password/g' vars \
    #
    # www.dba-oracle.com/t_ora_65096_create_user_12c_without_c_prefix.htm
    # required to make it compatible with Oracle 12c
    && for i in /transmart-data/ddl/oracle/GLOBAL/*.sql; do sed -i '1s/^/ALTER SESSION SET "_ORACLE_SCRIPT"=true;\n/' $i; done \
    && yum clean all && rm -rf /var/cache/yum

# TODO remove unnecessary directories (SOLR, Rserve, Config, etc)
WORKDIR /transmart-data

ENTRYPOINT ["/bin/bash", "-c", "source /transmart-data/vars; make -j4 oracle"]
