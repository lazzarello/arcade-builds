# Arcade Cabinet Software Build

This is the software produced from a project to make an arcade cabinet management system. Project notes are at https://blog.griftmarket.com/

## Game Stuff

*Kiosk Mode*

Gnome-kiosk creates a Gnome session that removes all interactive desktop features and runs a single shell script as the only application. This produces a more authentic retro arcade illusion by hiding any recognizable desktop PC bits. TODO: on some test systems, the mouse pointer does not dissapear after the game executable is launched.

This mode is the default graphical session after a new cabinet is provisioned in Operator Mode, documented below. To enter operator mode after provisioning, attach a keyboard and mouse to the host PC and press ctrl + alt + F3 followed by the Enter key. You will see a black screen with a text console. Type `operator-mode on` into the console. The host PC will reboot into Operator Mode, which is a Ubuntu Desktop session. From there it is possible to make changes to the Wifi settings, add custom logos, perform manual game updates...any more!

TODO: add a screenshot of the operator mode procedure

*gnome-kiosk build references*

https://help.gnome.org/admin/system-admin-guide/stable/lockdown-single-app-mode.html.en
https://discourse.gnome.org/t/gnome-kiosk-configuration/11807
https://gitlab.gnome.org/GNOME/gnome-kiosk

more than anyone wants to know about how snapcraft does automatic updates

https://forum.snapcraft.io/t/managing-updates/7022

*Operator Mode*

After installing a standard Ubuntu 24.04 desktop system from the official ISO, create a user named `user` and set a default password. Download the the release of this repository (TODO: make a release of this repository). Unzip the archive and enter this directory. Run `sudo ./autobuild.sh ${GAME}`, where the value for ${GAME} is the exact name of the snap package containing the game for this cabinet. Look in the `snaps/` directory for available names or create your own snaps. Type in the password you set for the user named `user`. This script will remove the password requirement for `user` to make operator mode work seamlessly. Do not reboot!

As `user` run `./user-settings.sh` 

## Snapcraft Packages for Games

Games are packaged as a snap using the canonical Snapcraft system. [Installation is simple](https://snapcraft.io/install/snapcraft/ubuntu) on a developmen Ubuntu desktop PC. The snapcraft.yaml files in the snaps directory demonstrate how to configure a custom snap for Windows binary releases of games. Currently these games are run via Wine. Binaries from Unity 3D and Game Maker Studio are tested. Other IDEs may work better in Valve's Proton, which is the runtime used on the Steam Deck and Steam on Linux.

The game archives are proprietary to the authors, so they are not included here. New game releases can be built by copying the ZIP archive of the game into the game's snapcraft directory and updating the filename and version in the game's snapcraft.yaml. From there a new build is done through typing `snapcraft` in the game directory.

Registering a private snap name is a manual process. All names must be unique in the whole Snap store, including private names. Unique names are registered by Canonical employees hours after a new name is registered.

*Releasing a Snap*

For new games, follow [Canonical's instructions](https://snapcraft.io/docs/releasing-to-the-snap-store) to get started. For updates to the snaps in this repo, upload a new build. Uploading a private snap is done after logging into the Snap as an owner or collaborator. For example, from the snap build directory, after a new build, run `snapcraft upload --release=latest/edge switch-n-shoot_1.3.6_amd64.snap` to upload version 1.3.6 (version specified in snapcraft.yaml) of switch-n-shoot to the latest/edge channel.

*Collaborators*

Private snaps can have a list of Ubuntu One users who are allowed to upload new releases. This is done through each snap's dashboard page. For example https://dashboard.snapcraft.io/snaps/perfect-pour/collaboration/ for the private snap Perfect Pour. **This URL is only visible to that game's collaborators.**

## Cloud stuff (optional)

Each cabinet can be managed as a single Ubuntu desktop through Canonical Landscape. What follows are the self-hosted instructions I followed for Google Cloud.

* Get a Google Cloud account and add a credit card.
* Install the `gcloud` [command line utility](https://ubuntu.com/landscape/docs/install-on-google-cloud)
* Follow along with that guide
* Get a DNS name for Landscape after the IP address step
* If you're using Google's DNS servers, add the IP address to the zone for a name like `landscape.example.com`

```
gcloud compute addresses list
gcloud dns managed-zones list
gcloud dns record-sets list --zone example
gcloud dns record-sets create landscape.example.com \
  --type=A --rrdatas=1.2.3.4 --ttl=60 --zone example
```

* Use the normal "quickstart" config in the guide
* Use the e2-medium, it's fine for small installations

For reference, here's the command line that starts the instance, with some customizations.

```
ZONE=us-west1-a
IMAGE_FAMILY=ubuntu-pro-2404-lts-amd64
gcloud compute instances create landscape \
    --zone $ZONE \
    --machine-type=e2-medium \
    --address landscape-external-ip \
    --tags http-server,https-server \
    --boot-disk-size 50 \
    --boot-disk-type pd-ssd \
    --image-family $IMAGE_FAMILY \
    --image-project ubuntu-os-pro-cloud \
    --metadata-from-file user-data=cloud-init.yaml
```

A potential problem here is if you don't get the networking tags right the first time, the SSL certificate fails. Rebooting doesn't try and validate it again. Also, if you skip the SMTP stuff, which requires a considerable amount of preparation to get the values to input, manually setting it up is quite difficult.

If either of these two problems happen and you're ambitious, you can [follow the manual installation guide.](https://ubuntu.com/landscape/install) This has all the information you need to step through any of the quickstart process that didn't work. You can also re-create the virtual machine after fixing any problems.

## Register A Landscape Client

After the first login to your Landscape server, you need to register a client. Click the link for client registration in the upper left corner and get the command line. Paste it into the game PC. This will bring up an interactive registration procedure. Any access groups you want to add must already exist before the host registration can be authorized on the server. Do not add an access token because you can authorize the registration on the server side.

## Landscape Outgoing Email

Outgoing Email is optional but can be nice. Email is required if you want to add a second administrator account. Just go with SendGrid and pay them money. There are a bunch of other ways to do it but I'll leave that exercise to the overachievers.

I set it up with MailGun's free service, which they hide. It took about an hour and a half to get right. I won't go into that here.

## Backing up Landscape

Docs are available at https://ubuntu.com/landscape/docs/backup-and-restore
