FROM groovy:2.4-jre7-alpine AS groovy

FROM openjdk:8-jdk-alpine

ENV I2B2_DATA_HOME /i2b2-data
ENV I2B2_VERSION 1.7.09.0001
ENV I2B2_DATA_NAME i2b2-data-$I2B2_VERSION
ENV I2B2_DATA_URL https://github.com/i2b2/i2b2-data/archive/v$I2B2_VERSION.zip
ENV I2B2_DATA_HOME /i2b2-data

ENV I2B2HIVE demouser
ENV I2B2DEMODATA demouser
ENV I2B2IMDATA demouser
ENV I2B2METADATA demouser
ENV I2B2PM demouser
ENV I2B2WORKDATA demouser

# Set Java options (see stackoverflow.com/questions/15464963)
ENV ANT_OPTS "-Duser.timezone=UTC -Djava.security.egd=file:///dev/urandom"

RUN apk upgrade --update --no-cache \
    && DEPENDENCIES="unzip zip" \
    && apk --no-cache --update add $DEPENDENCIES ca-certificates bash \
        apache-ant make curl php5 \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && ln -s /usr/bin/php5 /usr/bin/php \
    #
    # Get i2b2-data
    && curl -L $I2B2_DATA_URL -o $I2B2_DATA_NAME.zip \
    && unzip $I2B2_DATA_NAME.zip \
    && rm -rf $I2B2_DATA_NAME.zip \
    && mv $I2B2_DATA_NAME $I2B2_DATA_HOME \
    #
    # ISSUE: ojdbc14.jar does not work with Oracle 12 -Andre
    && rm $I2B2_DATA_HOME/edu.harvard.i2b2.data/Release_1-7/NewInstall/ojdbc14.jar \
    && ln -s $I2B2_DATA_HOME/oracle/lib/ojdbc6-12.1.0.2.jar \
        $I2B2_DATA_HOME/edu.harvard.i2b2.data/Release_1-7/NewInstall/ojdbc14.jar \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/

COPY --from=groovy $GROOVY_HOME $GROOVY_HOME

COPY oracle $I2B2_DATA_HOME/oracle
COPY postgres $I2B2_DATA_HOME/postgres
COPY Makefile $I2B2_DATA_HOME/
COPY vars $I2B2_DATA_HOME/

WORKDIR $I2B2_DATA_HOME


ENTRYPOINT ["/bin/bash", "-c"]
CMD ["env"]
