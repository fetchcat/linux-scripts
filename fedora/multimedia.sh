#! /usr/bin/bash

## Add Multimedia codecs
dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf install lame\* --exclude=lame-devel
dnf group upgrade --with-optional Multimedia

## Add any other sound/vid pkgs
dnf groupupdate sound-and-video