ARG PIHOLE_VERSION="latest"

FROM debian:bullseye AS build
RUN apt-get update \
 && apt-get install -y \
      curl

ARG COMMENT="Adding DOTE..."
ARG DOTE_ARM64_URL="https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64"
ARG DOTE_AMD64_URL="https://github.com/chrisstaite/DoTe/releases/latest/download/dote_linux"

# populated by [BuildKit](https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope)
ARG TARGETARCH

RUN echo $COMMENT \
 && export DOTE_URL="$( test "${TARGETARCH}" = "arm64" && echo "${DOTE_ARM64_URL}" || echo "${DOTE_AMD64_URL}" )" \
 && curl -fsSLo /usr/local/bin/dote "${DOTE_URL}" \
 && chmod +x /usr/local/bin/dote

FROM pihole/pihole:${PIHOLE_VERSION}

ENV DOTE_OPTS="-s 127.0.0.1:5053"

COPY s6-overlay /etc/s6-overlay
COPY --from=build /usr/local/bin/dote /usr/local/bin/dote

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
      dote \
 && apt-get update \
 && apt-get dist-upgrade -y \
 && rm -rf /var/lib/apt/lists/*

