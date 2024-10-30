#!/bin/bash
set -x
echo "this script changes user mode settings for operator mode visual appearance"

# Nautilus was removed in 24.04
# gsettings set org.gnome.nautilus.desktop trash-icon-visible false
gsettings set org.gnome.shell.extensions.ding show-trash false
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background primary-color '#000000'
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set com.ubuntu.update-notifier no-show-notifications true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 128

# add operator-mode script to executable path
mkdir ~/bin
cp kiosk-configuration/operator-mode ~/bin/
echo "PATH=\$PATH:\$HOME/bin" >> .bashrc
echo "Mark the desktop icon as trusted so it starts on double click"
cp kiosk-configuration/exit-operator-mode.desktop ~/Desktop/
chmod a+x ~/Desktop/exit-operator-mode.desktop
gio set ~/Desktop/exit-operator-mode.desktop "metadata::trusted" true
