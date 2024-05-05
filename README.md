# Doing Video Game Stuff on Linux

This is a collection of scripts and hand written notes gathered during a project to make an arcade cabinet management system. More details written at https://blog.griftmarket.com/

## Shell Scripts

They do stuff for operators setting up new cabinets.

## Cloud stuff

* Get a Google Cloud account and add a credit card.
* Install the `gcloud` [command line utility}(https://ubuntu.com/landscape/docs/install-on-google-cloud)
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

* Use the normal "quickstart" config in this repo
* Use the e2-medium, it's fine for small installations

A potential problem here is if you don't get the networking tags right the first time, the SSL certificate fails. Rebooting doesn't try and validate it again. Also, if you skip the SMTP stuff, which requires a considerable amount of preperation to get the values to input, manually setting it up is quite difficult.

Is there a Canonical supported way to replay some of the quickstart process?

Anyhoo...DSM arcade number one! We did it!

## Register a client

Click the link for client registration in the upper left corner and get the command line. It's that easy!

This will bring up an interactive registration procedure. Any access groups you want to add must already exist before the host registration can be authorized on the server. Do not add an access token because you can authorize the registration on the server side.

## Email

Email is optional but can he nice. It's my least favorite part of setting up any web service. Just go with SendGrid and pay them money. There are a bunch of other ways to do it but I'll leave that exercise to the overachievers.
