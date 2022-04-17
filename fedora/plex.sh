#! /usr/bin/bash

touch /etc/yum.repos.d/plex.repo
cat << EOF >> /etc/yum.repos.d/plex.repo
[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1
EOF

dnf upgrade
dnf install plexmediaserver
systemctl enable --now plexmediaserver

