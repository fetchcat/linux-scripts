#! /usr/bin/bash

cat << EOF >> /etc/dnf/dnf.conf
max_parallel_downloads=10
defaultyes=true
color=always
fastestmirror=true
EOF