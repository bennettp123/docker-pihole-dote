# docker-pihole-dote

An up-to-date version of [docker-pi-hole](https://github.com/pi-hole/docker-pi-hole), with DoTE.

Based on [boostchicken/pihole-dote:latest](https://hub.docker.com/layers/boostchicken/pihole-dote/latest/images/sha256-995c5f26aebcac386f2b5460e606c8f94b0100eccc4879bdb5d76da0fc1b4fee?context=explore), but with some small improvements:
* DoTE is baked into the image, instead of downloaded at launch. This should improve startup times, but it means you need to pull down the latest image whenever a new version of DoTE is released.
* DoTE is launched using s6-supervisor, which may improve reliability (automatically restarted when it fails)

## Usage

Follow the instructions here: https://github.com/boostchicken/udm-utilities/tree/master/run-pihole

However, update your scripts to use `bennettp123/pihole-dote:latest` instead of `pihole/pihole:latest`.

Note that DoTE is baked into the image, and not updated at reboot. DoTE can be updated along with pihole itself, by running `podman pull bennettp123/pihole-dote:latest`, then removing and recreating the pihole container.

Suggested changes to `upd_pihole.sh`:

```bash
#!/bin/sh

# Change to pihole/pihole:latest for default
# Change to boostchicken/pihole:latest for DoH
# Change to boostchicken/pihole-dote:latest for DoTE
IMAGE=bennettp123/pihole-dote:latest

CURRENT_IMAGE="$(podman image inspect --format '{{.Id}}' "${IMAGE}" 2>/dev/null || echo 'current image missing')"

podman pull "${IMAGE}"

NEW_IMAGE="$(podman image inspect --format '{{.Id}}' "${IMAGE}" 2>/dev/null || echo 'new image missing')"

if [ "${CURRENT_IMAGE}" != "${NEW_IMAGE}" ]; then
  exec /data/scripts/restart_pihole.sh
else
  echo "${IMAGE} is already up-to-date"
fi
```

Also, add a new script `restart_pihole.sh`:

```bash
#!/bin/sh

podman stop pihole >/dev/null 2>&1 || :
podman rm pihole >/dev/null 2>&1 || :

podman run -d \
    --network dns \
    --restart unless-stopped \
    --name pihole \
    -e TZ="Europe/London" \
    -v "/data/etc-pihole/:/etc/pihole/" \
    -v "/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --hostname pi.hole \
    -e DOTE_OPTS="-s [::1]:5053 -s 127.0.0.1:5053 -f [2606:4700:4700::1112]:853 -f [2606:4700:4700::1002]:853 -f 1.1.1.2:853 -f 1.0.0.2:853 -h security.cloudflare-dns.com -m 512" \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_='::1#5053;127.0.0.1#5053' \
    -e ServerIP='10.0.5.3' \
    -e IPv6="true" \
    bennettp123/pihole-dote:latest
```

You can run `upd_pihole.sh` periodically, and it will restart your container when it detects an update is available.
