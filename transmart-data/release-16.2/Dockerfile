FROM groovy:2.4-jre7-alpine AS groovy

###########################
# Build transmart-data
########################
FROM openjdk:7-jre-alpine

COPY --from=groovy $GROOVY_HOME $GROOVY_HOME

ENV TRANSMART_VERSION release-16.2
ENV TRANSMART_DATA_NAME transmart-data-$TRANSMART_VERSION
ENV TRANSMART_DATA_URL http://library.transmartfoundation.org/release/release16_2_0_artifacts/$TRANSMART_DATA_NAME.zip

ENV TRANSMART_DATA_HOME /transmart-data

# Set Java options (see stackoverflow.com/questions/15464963)
ENV JAVA_OPTS "-Duser.timezone=UTC -Djava.security.egd=file:///dev/urandom"

RUN apk upgrade --update --no-cache \
    && DEPENDENCIES="unzip zip" \
    && apk --no-cache --update add $DEPENDENCIES curl bash make php5-dev php5-json \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && ln -s /usr/bin/php5 /usr/bin/php \
    #
    # Get transmart-data
    && curl $TRANSMART_DATA_URL -o $TRANSMART_DATA_NAME.zip \
    && unzip $TRANSMART_DATA_NAME.zip \
    && rm -rf $TRANSMART_DATA_NAME.zip \
    && mv $TRANSMART_DATA_NAME $TRANSMART_DATA_HOME \
    && cd $TRANSMART_DATA_HOME \
    #
    # remove localhost references
    && sed -i 's/localhost/solr/g' solr/Makefile \
    #
    # Install opencsv
    # Way too many times this fails to during database schema install. Just download it here.
    # Used by CsvLoader.groovy - Andre
    && groovy -Dgroovy.grape.report.downloads=true -e 'groovy.grape.Grape.grab(group:"net.sf.opencsv", module:"opencsv", version:"2.3");' \
    #
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/*




# too many localhost references. copy new Config-template.groovy
# no more localhost references! -Andre
COPY Config-template.groovy $TRANSMART_DATA_HOME/config/

# modified vars file. works with Docker's existing configurable env
# no more editing vars (almost)! -Andre
COPY vars $TRANSMART_DATA_HOME/


WORKDIR $TRANSMART_DATA_HOME

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["env"]


#### Postgres work
#RUN apk upgrade --update && apk add make

#RUN apk upgrade --update
#RUN apk search -v 'psql' && apk add psqlodbc
#RUN apk add postgresql-client


    #
    # Use environment variables
#RUN sed -i 's/PGHOST\=.*$/PGHOST\=\$POSTGRES_HOST/g' vars \
#    && sed -i 's/PGPASSWORD\=.*$/PGPASSWORD\=\$POSTGRES_PASS/g' vars \
#    && sed -i 's/PGPASSWORD\=.*$/PGPASSWORD\=\$POSTGRES_PASS/g' vars \
    #&& sed -i 's/TABLESPACES\=.*$/TABLESPACES\=\/var\/lib\/postgresql\/tablespaces\//g' vars \
    #
    # Cannot create Postgres Database in a transaction block
    # remove --single-transaction command option
    # https://www.postgresql.org/docs/9.3/static/sql-createdatabase.html
#    && sed -i 's/^\(.*\)\(\$(PSQL_COMMAND)\)\(.*CREATE\sDATABASE.*\)$/\1psql -v ON_ERROR_STOP\=1 -X\3/g' ddl/postgres/GLOBAL/Makefile \
#    && sed -i 's/^\(.*\)\(\$(PSQL_COMMAND)\)\(.*CREATE\sTABLESPACE.*\)$/\1psql -v ON_ERROR_STOP\=1 -X\3/g' ddl/postgres/GLOBAL/Makefile \
#    && cat ddl/postgres/GLOBAL/Makefile

#RUN make -C env /var/lib/postgresql/tablespaces
