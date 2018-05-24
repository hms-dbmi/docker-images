### Requires transmart-data ###
FROM dbmi/transmart-data:release-16.2 AS transmart-data


### Build Rserve ###
FROM openjdk:7-jdk-alpine AS install_rserve

ENV TRANSMART_DATA_HOME /transmart-data
COPY --from=transmart-data /transmart-data $TRANSMART_DATA_HOME

# transmart-data mirror does not work.
ENV R_MIRROR http://cran.r-project.org

# required to compile Rcpp on alpine
ENV R_FLAGS "$CXXFLAGS -D__MUSL__"

# required to configure for alpine
ENV r_cv_libc_stack_end no

# dummy env variable
ENV TABLESPACES dummy

WORKDIR $TRANSMART_DATA_HOME

RUN DEPENDENCIES=" \
    cairo-dev \
    gcc \
    g++ \
    gfortran \
    readline-dev \
    libxt-dev \
    pango-dev \
    texinfo \
    make \
    curl" \
    && apk upgrade \
    && apk --no-cache --update add $DEPENDENCIES \
    #
    # QDNAseq_1.10.0 no longer available at bioconductor.org - Andre
    # downloading R packages fails. h/t @dennyverbeeck
    # QDNAseq_1.14.0 no longer available (my previous fix)
    # TODO: get available version number first  - Andre
    && sed -i 's/QDNAseq_1\.10\.0/QDNAseq_1\.16\.0/g' R/other_pkg.R \
    && until make -C R install_packages; do echo "Failed, retrying..."; done \
    #
    # fix nodaemon conf
    && sed -i 's/deamon/daemon/' $TRANSMART_DATA_HOME/R/Rserv_nodaemon.conf \
    && echo "remote enable" >> $TRANSMART_DATA_HOME/R/Rserv_nodaemon.conf \
    && rm -rf R/build \
    && rm -rf R/R-* \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/*

## Get Rscripts ##
FROM alpine:3.7 AS install_scripts

ARG version
ARG artifact_url
ARG artifact

ENV ARTIFACT Rmodules
ENV ARTIFACT_VERSION ${version:-release-16.2}
ENV ARTIFACT_URL ${artifact_url:-https://github.com/i2b2-tranSMART/${ARTIFACT}/archive}
ENV ARTIFACT_REL ${artifact:-web-app/Rscripts}

ENV RSCRIPT_INSTALL_DIR /Rscripts

RUN apk upgrade --update --no-cache \
    && DEPENDENCIES="curl unzip" \
    && apk --no-cache --update add $DEPENDENCIES \
    #
    # get Rscripts
    #
    && curl -L ${ARTIFACT_URL}/${ARTIFACT_VERSION}.zip -o ${ARTIFACT}-${ARTIFACT_VERSION}.zip \
    && unzip ${ARTIFACT}-${ARTIFACT_VERSION}.zip \
    && mv ${ARTIFACT}-${ARTIFACT_VERSION}/${ARTIFACT_REL} $RSCRIPT_INSTALL_DIR \
    #
    # sanity check
    && ls -a $RSCRIPT_INSTALL_DIR \
    #
    # clean up
    && rm -rf ${ARTIFACT}-${ARTIFCAT_VERSION}* \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/*

### Rserve production ###
FROM alpine:3.7 AS production

ENV RSERVE_HOME /transmart-data/R
WORKDIR $RSERVE_HOME

# copy executables, libs, and conf, respectively
COPY --from=install_Rserve $RSERVE_HOME/root/bin/* /usr/bin/
COPY --from=install_Rserve $RSERVE_HOME/root/lib $RSERVE_HOME/root/lib
COPY --from=install_Rserve $RSERVE_HOME/Rserv_nodaemon.conf /etc/Rserv.conf

COPY --from=install_scripts $RSCRIPT_INSTALL_DIR $RSERVE_HOME

RUN apk upgrade \
    && apk --no-cache --update add cairo readline libxt \
        pcre libbz2 pango libgomp \
        gfortran zlib ttf-dejavu bash \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    && rm -rf /var/cache/apk/*


ENTRYPOINT ["R", "CMD"]

# "daemon no" option in Rserv.conf does not work
# to run Rserve in the main process requires using the debug executable - Andre
CMD ["Rserve.dbg", "--vanilla", "--RS-conf", "/etc/Rserv.conf"]
