FROM wnagele/rserve:latest
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

# install linux libraries required R libraries
RUN apt-get install -y --force-yes \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libcurl4-openssl-dev

# install AWS client (required by i2b2transmart)
RUN apt-get install -y awscli

# work directory (required by i2b2transmart)
ENV RSERVE_DIR /mnt/tmp/jobs
RUN mkdir -p $RSERVE_DIR

COPY ./scripts /scripts

# Required R libraries for transmart
# https://wiki.transmartfoundation.org/display/TSMTGPL/Installing+Rserve
ENV R_BIO_URL http://bioconductor.org/biocLite.R
ENV R_BIO_PKG impute,multtest,preprocessCore,GO.db,AnnotationDbi

ENV R_REPO_CRAN http://cran.us.r-project.org
ENV GGPLOT_PACKAGES digest,gtable,scales,proto,devtools,ggplot2
ENV R_PKG_CRAN $GGPLOT_PACKAGES,Rserve,Cairo,MASS,stringr,plyr,reshape2,gplots,data.table,WGCNA

RUN Rscript ./scripts/install_bio.R
RUN Rscript ./scripts/install_pkgs.R

# Verify all libraries are installed
RUN Rscript --no-save --no-restore --no-site-file --no-environ ./scripts/testCairo.R

# ENTRYPOINT/CMD: using wnagele/rserve default CMD (./run.sh)
