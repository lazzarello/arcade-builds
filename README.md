# Doing Video Game Stuff on Linux

This is a collection of scripts and hand written notes gathered during a project to make an arcade cabinet management system. More details written at https://blog.griftmarket.com/

## Game Stuff

*Experimental Kiosk mode!*

Gnome-kiosk creates a Gnome session that removes all interactive desktop features and runs a single shell script as the only application. 

*Manual desktop mode*

For cabinets running a stock Ubuntu Linux PC, there are two shell scripts in this repository to serve as a starting point for your own bootstrapping preferences. After installing the base OS and creating an unprivileged user, run the autobuild.sh script as root. This changes a couple things to make it function more like a kiosk. It disables all automatic updates.

All the Gnome desktop settings and application startup bits can be automated through the user-settings.sh and .desktop files. The example application is Xeyes.

Each game is packaged as a snap using the canonical Snapcraft system. The snapcraft.yaml files in the snaps directory demonstrate how to build a custom snap for each type of binary. The game archives are proprietary to the authors, so they are not included here. You can use any .zip archive output from GSM v2. The Unity games run a Windows binary through Wine.

Registering a private snap name is a manual process. All names must be unique in the whole Snap store, including private names. Unique names are registered by Canonical employees hours after a new name is registered.

Uploading a private snap is done after logging into the Snap store with a valid Ubuntu One account and registering the name. After the name is registered for example, run `snapcraft upload --release=latest/edge switch-n-shoot_1.3.6_amd64.snap` to upload version 1.3.6 (version specified in snapcraft.yaml) of switch-n-shoot to the latest/edge channel.

## Cloud stuff

Each cabinet is managed as a single Ubuntu desktop through Canonical Landscape. What follows are the self-hosted instructions I followed for Google Cloud.

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

## Register a client

After the first login to your Landscape server, you need to register a client. Click the link for client registration in the upper left corner and get the command line. Paste it into the game PC. This will bring up an interactive registration procedure. Any access groups you want to add must already exist before the host registration can be authorized on the server. Do not add an access token because you can authorize the registration on the server side.

## Email

Outgoing Email is optional but can be nice. Email is required if you want to add a second administrator account. Just go with SendGrid and pay them money. There are a bunch of other ways to do it but I'll leave that exercise to the overachievers.

I set it up with MailGun's free service, which they hide. It took about an hour and a half to get right. I won't go into that here.
