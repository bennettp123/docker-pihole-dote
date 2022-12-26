ARG PIHOLE_VERSION="latest"

FROM debian:bullseye AS build
RUN apt-get update \
    && apt-get install -y \
       curl

ARG COMMENT="Adding DOTE..."
ARG DOTE_URL="https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64"

RUN echo $COMMENT \
    && curl -fsSLo /usr/local/bin/dote "${DOTE_URL}" \
    && chmod +x /usr/local/bin/dote

COPY s6-overlay /etc/s6-overlay

FROM pihole/pihole:${PIHOLE_VERSION}
ENV DOTE_OPTS="-s 127.0.0.1:5053"
RUN addgroup \
        --system \
        --gid 733 \
        dote \
    && adduser \
        --system \
        --uid 733 \
        --gid 733 \
        --disabled-login \
        --disabled-password \
        --home /nonexistant \
        --no-create-home \
        --gecos '' \
        dote
COPY --from=build /usr/local/bin/dote /usr/local/bin/dote

