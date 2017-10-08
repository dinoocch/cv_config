#!/bin/sh

# Seconds before we kill the user.  2700 seconds = 45 minutes
KILLSECONDS=2700

screensaver_kill() {
    lockedtime=0
    person=$1
    display=$2
    if pgrep -u "$person" cinnamon-screen > /dev/null 2>&1; then
        echo "Using Cinnamon-Screensaver"
        lockedtime=$(sudo -u "$person" DISPLAY="$display" cinnamon-screensaver-command --time | grep -Eo '[0-9]+')
    elif pgrep -u "$person" xscreensaver > /dev/null 2>&1; then
        echo "Using XScreenSaver"
        xscreentime=$(sudo -u "$person" DISPLAY="$display" xscreensaver-command --time | sed '/locked/!d;s/^.*since //;s/(.*$//')
        if [ -z "$xscreentime" ] ; then
            echo "XScreenSaver is not currently locked!"
            return
        fi
        now="$(date '+%s')"
        xscreendate="$(date -d "$xscreentime" +%s)"
        lockedtime="$((now - xscreendate))"
        echo "XScreenTime: $xscreentime"
        echo "Now: $now"
        echo "XScreenDate: $xscreendate"
    fi
    if [ -z "$lockedtime" ]; then
        return
    fi
    echo "LockedTime: $lockedtime"

    if [ "$lockedtime" -ge "$KILLSECONDS" ]; then
        pkill -KILL -u "$person"
    fi

}

for session in $(loginctl list-sessions | awk '/seat0/ { print $1 }')
do
    active=$(loginctl -p Active --value show-session "$session")
    person=$(loginctl -p Name --value show-session "$session")
    display=$(loginctl -p Display --value show-session "$session")

    if [ "$person" = "sddm" ]; then
        echo "sddm user. Skipping."
        continue
    fi

    if [ -z "$display" ]; then
        echo "No display. Skipping."
        continue
    fi

    if [ "$active" = "no" ]; then
        echo "Inactive User: $person"
        pkill -KILL -u "$person"
        continue
    fi

    screensaver_kill "$person" "$display"

done
