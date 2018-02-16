ARG SERVICE=latest
ARG VERSION=latest
FROM dbmi/secret-getter:latest AS secrets
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>


FROM dbmi/$SERVICE:$VERSION

COPY --from=secrets /usr/bin/vault_getter /usr/bin/
