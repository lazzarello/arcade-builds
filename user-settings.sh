#!/bin/bash
set -x
echo "this script changes user mode settings for game playback and visual appearance"

gsettings set org.gnome.desktop.bluetooth bluetooth-enabled false
gsettings set org.gnome.nautilus.desktop trash-icon-visible false
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background primary-color '#000000'
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.notifications show-banners false
gsettings set com.ubuntu.update-notifier no-show-notifications true
landscape-sysinfo

echo "Mark the desktop icon as trusted so it starts on double click"
cp start-game.desktop ~/Desktop/
gio set ~/Desktop/start-game.desktop "metadata::trusted" yes
# Autostart game, do these two files need to differ?
mkdir -p ~/.config/autostart/
cp auto-start-game.desktop ~/.config/autostart/start-game.desktop
