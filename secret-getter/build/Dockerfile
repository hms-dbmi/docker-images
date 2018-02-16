FROM golang:1.10-rc-alpine AS builder

ENV SECRET_GETTER_REPO https://github.com/hms-dbmi/vault-getter.git
ENV SECRET_GETTER_VERSION 0.9

RUN apk update && DEPENDENCIES="make git" \
    && apk --no-cache add $DEPENDENCIES \
    && git clone $SECRET_GETTER_REPO \
    && cd vault-getter \
    && make all \
    && cd .. \
    && rm -rf vault-getter \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/


#### production secret-getter ###
FROM scratch

COPY --from=builder /go/bin/vault_getter /usr/bin/

ENTRYPOINT ["/usr/bin/vault_getter"]
# example command line options
CMD ["--help"]
