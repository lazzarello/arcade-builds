#!/bin/bash

echo "this script changes system settings as root for bootup and package settings"

apt-get update && apt-get upgrade -y
# https://ubuntu.com/landscape/docs/install-landscape-client
# apt-get install -y landscape-client
snap install landscape-client
apt remove -y unattended-upgrades update-notifier

# REF: https://askubuntu.com/questions/1322292/how-do-i-turn-off-automatic-updates-completely-and-for-real
cat <<-EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

echo "enabled=0" > /etc/default/apport

cat <<-EOF > /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_DISABLE_RECOVERY="true"
EOF

update-grub

# /usr/share/plymouth theme goes here
# yikes, Plymouth is a whole thing...https://wiki.ubuntu.com/Plymouth#Splash_Theme
