ARG base_image=scratch
ARG image_tag=latest

FROM golang:1.10-rc-alpine AS builder

ARG version

ENV SECRET_GETTER_REPO https://github.com/hms-dbmi/secret-getter.git
ENV SECRET_GETTER_VERSION ${version:-master}

RUN apk update && DEPENDENCIES="make git" \
    && apk --no-cache add $DEPENDENCIES \
    && git clone $SECRET_GETTER_REPO -b ${SECRET_GETTER_VERSION} \
    && cd secret-getter \
    && make all \
    && cd .. \
    && rm -rf secret-getter \
    && apk del $DEPENDENCIES && rm -rf /var/cache/apk/

#### secret-getter executable ###
FROM scratch AS executable

COPY --from=builder /go/bin/secret_getter /usr/bin/

#### secret-getter runtime ###
FROM ${base_image}:${image_tag} AS runtime

COPY --from=executable /usr/bin/ /usr/bin/

ENTRYPOINT ["/usr/bin/secret_getter"]
# example command line options
CMD ["--help"]
