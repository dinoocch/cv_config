#!/bin/sh
if [ -d "/mnt/council_scroller/scroller" ]; then
    rm /opt/announcements/*
    rsync /mnt/council_scroller/scroller/ /opt/announcements/
fi
