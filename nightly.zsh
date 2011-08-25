#!/bin/zsh

# Script to do time-consuming stuff that does not need your attention
# while you go to sleep, and suspend the computer after the job is done

rm -f /tmp/shutdown.file
su -c "(while [ ! -f \"/tmp/shutdown.file\" ]; do sleep 60; done; pm-suspend) &"

## Do time consuming stuff here (compile linux?) while you sleep

touch /tmp/shutdown.file

