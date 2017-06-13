#!/bin/bash

# Wait until we can talk to the repo
while true; do
    if ping -c1 repo.collegiumv.org ; then
        break
    fi
    sleep 5
done

# This script runs the first boot install tasks on the hardware
xbps-install -R http://repo.collegiumv.org/current -Syu
xbps-install -R http://repo.collegiumv.org/current -Syu
xbps-install -R http://repo.collegiumv.org/current -y git-all python-virtualenv base-devel python-devel libffi-devel libressl-devel

# Install ansible requirements
virtualenv /tmp/firstboot-depends
source /tmp/firstboot-depends/bin/activate
xbps-uhelper fetch "http://preseed.collegiumv.org/requirements.txt>/tmp/requirements.txt"
pip install -r /tmp/requirements.txt

# Attempt to run the main ansible installer
ansible-pull --accept-host-key -U https://github.com/collegiumv/cv_config.git workstation.yml

# Remove the firstboot script
rm -rf /etc/sv/firstboot
rm -rf /var/service/firstboot

# Reboot so that everything starts up cleanly
shutdown -r now
