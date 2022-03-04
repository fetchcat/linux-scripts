#!/bin/bash

echo "Installing and configuring UFW"

pacman -S ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22

cat << EOF > /etc/ufw/applications.d/PlexMediaServer
[PlexMediaServer]
title=Plex Media Server
description=This opens up PlexMediaServer for http (32400), upnp, and autodiscovery.
ports=32469/tcp|32413/udp|1900/udp|32400/tcp|32412/udp|32410/udp|32414/udp
EOF

ufw allow PlexMediaServer
ufw enable

echo "UFW enabled"
