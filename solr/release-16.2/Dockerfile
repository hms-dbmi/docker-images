### Requires transmart-data ###
FROM dbmi/transmart-data:release-16.2 AS transmart-data


### Build SOLR ###
FROM alpine:3.6 AS install_solr
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# install solr
# options: db_type: postgres, oracle
ARG db_type

ENV DB_TYPE ${db_type:-oracle}
ENV TRANSMART_DATA_HOME /transmart-data
COPY --from=transmart-data /transmart-data $TRANSMART_DATA_HOME

WORKDIR $TRANSMART_DATA_HOME
RUN apk upgrade --update \
    && DEPENDENCIES="unzip zip tar curl php5-dev php5-json make coreutils rsync" \
    && apk --no-cache --update add $DEPENDENCIES bash \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && ln -s /usr/bin/php5 /usr/bin/php \
    ##
    ## bugs in transmart-data solr install -Andre
    ## 1. complains no solrconfig-patched.xml exists
    ## 2. complains dist: not found in archive
    ##
    && sed -i 's/p0 </p0 solrconfig.xml/g' solr/Makefile \
    && sed -i 's/--touch/--touch --ignore-failed-read/g' solr/Makefile \
    && bash -c "source vars; make -C solr solr_home" \
    && rm -rf /transmart-data/solr/*.tgz \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/


### SOLR Production ###
FROM openjdk:7-jre-alpine

ENV SOLR_HOME /opt/solr
EXPOSE 8983

COPY --from=install_solr /transmart-data/solr/ $SOLR_HOME
WORKDIR $SOLR_HOME

ENTRYPOINT ["java", "-jar", "start.jar"]
