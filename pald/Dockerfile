FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates

# server
COPY ./bin/pald /usr/bin/pald

# red october, pgp, notary configuration
COPY ./config.yaml /etc/pal/config.yaml

VOLUME /var/run

ENTRYPOINT ["/usr/bin/pald", \
    "-addr=unix:///var/run/pald.sock", \
    "-config=/etc/pal/config.yaml", \
    "-env=dev"]
