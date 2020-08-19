# Images

Contrary to an LXD managed cluster, you have to specify which images should be available on the hosts.

To add a new image to the list of images to be synced, create an image object at `/api/image/`
with e.g. 

    "sync": true,
    "server": "https://cloud-images.ubuntu.com/releases",
    "protocol": "simplestreams",
    "alias": "x"

Make sure that the images have a working `cloud-init` installed, as this is necessary for automatic provisioning