FROM dbmi/transmart-data:release-16.2
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV KETTLE_VERSION 4.4.0
ENV KETTLE_NAME pdi-ce-$KETTLE_VERSION-stable
ENV KETTLE_ARCHIVE http://downloads.sourceforge.net/project/pentaho/Data%20Integration/$KETTLE_VERSION-stable/$KETTLE_NAME.tar.gz
ENV KETTLE_HOME $TRANSMART_DATA_HOME/env/data-integration

ENV TRANSMART_ETL_VERSION release-16.2
ENV TRANSMART_ETL_NAME tranSMART-ETL-$TRANSMART_ETL_VERSION
ENV TRANSMART_ETL_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/$TRANSMART_ETL_NAME.zip
ENV TRANSMART_ETL_HOME $TRANSMART_DATA_HOME/env/transmart-ETL

WORKDIR $TRANSMART_DATA_HOME

RUN apk upgrade --update --no-cache \
    && DEPENDENCIES="tar gzip unzip maven coreutils xz" \
    && apk --no-cache --update add $DEPENDENCIES curl \
#    && rm /bin/sh && ln -s /bin/bash /bin/sh \
#    && ln -s /usr/bin/php5 /usr/bin/php \
    && env \
    && source ./vars; make -C env data-integration \
    && make update_datasets \
    #
    # Remove Unnecessary files
    && rm -rf env/data-integration/plugins* \
    && rm -rf env/data-integration/docs* \
    #
    # Install kettle / data-integration
    #&& curl -L -f -o $KETTLE_NAME.tar.gz $KETTLE_ARCHIVE \
    #&& tar zxvf $KETTLE_NAME.tar.gz \
    #&& rm -rf env/$KETTLE_NAME.tar.gz \
    #
    #
    # Install transmart-etl
    && curl $TRANSMART_ETL_URL -o $TRANSMART_ETL_NAME.zip \
    && unzip $TRANSMART_ETL_NAME.zip \
    && rm -rf $TRANSMART_ETL_NAME.zip \
    && mv $TRANSMART_ETL_NAME transmart-ETL \
    #
    # Unnecessary for command line kettle etl
    && rm -rf transmart-ETL/FCL4tranSMART \
    && rm -rf /root/.m2 && apk del $DEPENDENCIES && rm -rf /var/cache/apk/* \
    ### TODO: Are we not using the mvn package call?
    ## If no maven, no need for source files
    && rm -rf transmart-ETL/src* \
    && rm -rf env/$KETTLE_NAME.tar.gz \
    && mv transmart-ETL env/transmart-ETL

ENV KETTLE_JOBS_PSQL /transmart-data/env/transmart-ETL/Postgres/GPL-1.0/Kettle/Kettle-ETL/
ENV KETTLE_JOBS_ORA /transmart-data/env/transmart-ETL/Kettle-GPL/Kettle-ETL/
ENV R_JOBS_PSQL /transmart-data/env/transmart-ETL/Kettle/postgres/R/
ENV KITCHEN /transmart-data/env/data-integration/kitchen.sh

COPY kettle.properties /transmart-data/env/transmart-ETL/Kettle-GPL/Kettle_Properties/
COPY kettle.properties /transmart-data/env/transmart-ETL/Postgres/GPL-1.0/Kettle/


ENTRYPOINT ["/bin/bash", "-c"]
CMD ["env"]
    #
    # replace Postgres DB assumptions with environment variables
#RUN cd env \
#    && sed -i 's/^\(.*_SERVER\=\).*$/\1\${POSTGRES_HOST}/g' transmart-ETL/Postgres/GPL-1.0/Kettle/kettle.properties \
#    && sed -i 's/^\(.*_PORT\=\).*$/\1\${POSTGRES_PORT}/g' transmart-ETL/Postgres/GPL-1.0/Kettle/kettle.properties \
#    && cat transmart-ETL/Postgres/GPL-1.0/Kettle/kettle.properties
