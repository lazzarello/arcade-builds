#!/bin/bash
set -ex

GAME=$1
echo "this script changes system settings as root for bootup and package settings"
echo "installing for ${GAME}"
echo "this requires a valid Ubuntu One login to be present in the file ~/.snap/auth.json. generating one interactively"
su - user -c "snap login"
snap install --stable ${GAME}

apt-get update && apt-get upgrade -y
# https://ubuntu.com/landscape/docs/install-landscape-client
apt-get install -y gnome-kiosk
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

function kiosk_mode {
  GDM_PATH="/etc/gdm3/custom.conf"
  # DEFAULT_SESSION must be the same name as the WAYLAND_SESSION file excluding the .desktop extension
  DEFAULT_SESSION="gnome-kiosk-script-wayland"
  DEFAULT_SESSION_PATH="/var/lib/AccountsService/users/user"
  KIOSK_SCRIPT="/home/user/.local/bin/gnome-kiosk-script"
  KIOSK_SESSION="/usr/share/gnome-session/sessions/gnome-kiosk-script.session"
  WAYLAND_SESSION="/usr/share/wayland-sessions/gnome-kiosk-script-wayland.desktop"

cat <<-EOF > $DEFAULT_SESSION_PATH
[User]
Session=$DEFAULT_SESSION
Icon=/home/user/.face
SystemAccount=false

[InputSource0]
xkb=us
EOF

cat <<-EOF > $GDM_PATH
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=user
EOF

su - user -c "mkdir -p ~/.local/bin"
cat <<-EOF > $KIOSK_SCRIPT
/snap/bin/$1
# loop to test for crash detection and restart this script
sleep 1.0
exec "\$0" "\$@"
EOF

chown user:user $KIOSK_SCRIPT
chmod 755 $KIOSK_SCRIPT

cat <<-EOF > $KIOSK_SESSION
[GNOME Session]
Name=Kiosk
RequiredComponents=org.gnome.Kiosk;org.gnome.Kiosk.Script;
EOF

cat <<-EOF > $WAYLAND_SESSION
[Desktop Entry]
Name=Kiosk Script Session (Wayland)
Comment=Logs you into the session started by ~/.local/bin/gnome-kiosk-script
Exec=gnome-session --session gnome-kiosk-script
TryExec=gnome-session
Type=Application
DesktopNames=GNOME-Kiosk;GNOME;
X-GDM-SessionRegisters=true
X-GDM-CanRunHeadless=true
EOF
}

# enable operator TTY at ctrl + alt + F3
cp kiosk-configuration/autologin@.service /etc/systemd/system/
systemctl enable autologin@tty3.service
systemctl start autologin@tty3.service
echo "user  ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/user-nopassword
# write out all kiosk mode configuration 
kiosk_mode $GAME

# enable fail-safe game mode on n + 1 reboot after entering operator mode
cp kiosk-configuration/ensure-kiosk-mode.service /etc/systemd/system/ensure-kiosk-mode.service
systemctl enable ensure-kiosk-mode.service

# write out the fail-safe shell script
cat <<-EOF > /usr/local/bin/ensure-kiosk-mode.sh
#!/bin/bash
if [ -f "/usr/local/share/operator-mode" ]; then
	sed -i 's/gnome-kiosk-script-wayland/ubuntu/g' /var/lib/AccountsService/users/user
	rm /usr/local/share/operator-mode
else
	sed -i 's/ubuntu/gnome-kiosk-script-wayland/g' /var/lib/AccountsService/users/user
fi
EOF
chmod 755 /usr/local/bin/ensure-kiosk-mode.sh

# register to landscape (optional) TODO: make this a script option
# landscape-client.config --computer-title "${GAME}" --account-name standalone  --url https://landscape.dsmarcade.com/message-system --ping-url http://landscape.dsmarcade.com/ping
#
# bootup logo theme goes here
# yikes, Plymouth is a whole thing...https://wiki.ubuntu.com/Plymouth#Splash_Theme
