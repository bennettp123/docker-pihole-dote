ARG COMMENT="Adding DOTE..."
ARG DOTE_URL="https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64"
ARG PIHOLE_VERSION="latest"

FROM debian:bullseye AS build
RUN apt-get update \
    && apt-get install -y \
       curl

RUN echo ${COMMENT} \
    && curl -fsSLo /usr/local/bin/dote ${DOTE_URL} \
    && chmod +x /usr/local/bin/dote

FROM pihole/pihole:${PIHOLE_VERSION}
ENV DOTE_OPTS="-s 127.0.0.1:5053"
RUN mkdir -p /etc/cont-init.d \
    && echo -e  "#!/bin/sh\n/usr/local/bin/dote \\\$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh \
    && chmod +x /etc/cont-init.d/10-dote.sh
COPY --from=build /usr/local/bin/dote /usr/local/bin/dote

