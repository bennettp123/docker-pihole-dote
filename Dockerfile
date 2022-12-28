ARG PIHOLE_VERSION="latest"

FROM debian:bullseye AS build
RUN apt-get update \
    && apt-get install -y \
       curl

RUN curl -sSL https://git.io/get-mo -o /usr/local/bin/mo \
    && chmod +x /usr/local/bin/mo

ARG COMMENT="Adding DOTE..."
ARG DOTE_URL="https://github.com/chrisstaite/DoTe/releases/latest/download/dote_{{SUFFIX}}"

RUN echo $COMMENT \
    && export SUFFIX="$( test "${TARGETARCH}" = "arm64" && echo "${TARGETARCH}" || echo linux )" \
    && export DOTE_URL="$( echo "${DOTE_URL}" | mo -u)" \
    && curl -fsSLo /usr/local/bin/dote "${DOTE_URL}" \
    && chmod +x /usr/local/bin/dote

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
COPY s6-overlay /etc/s6-overlay
COPY --from=build /usr/local/bin/dote /usr/local/bin/dote

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

