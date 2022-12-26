# docker-pihole-dote

An up-to-date version of [docker-pi-hole](https://github.com/pi-hole/docker-pi-hole), with DoTE enabled.

Based on [boostchicken/pihole-dote:latest](https://hub.docker.com/layers/boostchicken/pihole-dote/latest/images/sha256-995c5f26aebcac386f2b5460e606c8f94b0100eccc4879bdb5d76da0fc1b4fee?context=explore), but with some small improvements:
* DoTE is baked into the image, instead of downloaded at launch. This should improve startup times, but it means you need to pull down the latest image whenever a new version of DoTE is released.
* DoTE is launched using s6-supervisor, which may improve reliability (automatic restarted if it fails)

