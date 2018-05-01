### Requires transmart-data ###
FROM dbmi/transmart-data:release-16.2 AS transmart-data


### Build Rserve ###
FROM openjdk:7-jdk-alpine AS install_Rserve

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
    && apk --no-cache --update add $DEPENDENCIES bash \
    && rm /bin/sh && ln -s /bin/bash /bin/sh \
    #
    # QDNAseq_1.10.0 no longer available at bioconductor.org - Andre
    # downloading R packages fails. h/t @dennyverbeeck
    && sed -i 's/QDNAseq_1\.10\.0/QDNAseq_1\.14\.0/g' R/other_pkg.R \
    && until make -C R install_packages; do echo "Failed, retrying..."; done \
    #
    # fix nodaemon conf
    && sed -i 's/deamon/daemon/' $TRANSMART_DATA_HOME/R/Rserv_nodaemon.conf \
    && echo "remote enable" >> $TRANSMART_DATA_HOME/R/Rserv_nodaemon.conf \
    && rm -rf R/build \
    && rm -rf R/R-* \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/*


### Rserve production ###
FROM alpine:3.7 AS production

# copy executables, libs, and conf, respectively
COPY --from=install_Rserve /transmart-data/R/root/bin/* /usr/bin/
COPY --from=install_Rserve /transmart-data/R/root/lib /transmart-data/R/root/lib
COPY --from=install_Rserve /transmart-data/R/Rserv_nodaemon.conf /etc/Rserv.conf

RUN apk upgrade \
    && apk --no-cache --update add cairo readline libxt pcre libbz2 pango libgomp gfortran zlib \
    #
    # package readline-7 not available on Alpine -Andre
    && ln -s libreadline.so.6 /usr/lib/libreadline.so.7 \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["R", "CMD"]

# "daemon no" option in Rserv.conf does not work
# to run Rserve in the main process requires using the debug executable - Andre
CMD ["Rserve.dbg", "--vanilla", "--RS-conf", "/etc/Rserv.conf"]
