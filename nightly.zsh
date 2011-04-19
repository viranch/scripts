#!/bin/zsh

rm -f /tmp/shutdown.file
su -c "(while [ ! -f \"/tmp/shutdown.file\" ]; do sleep 60; done; pm-suspend) &"

zsh ~/kde/doit.sh
touch /tmp/shutdown.file

