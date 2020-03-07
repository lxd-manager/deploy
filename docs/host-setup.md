# Host Setup for lxd-manager

### Interfaces

* Create a bridge `lxdextern` with the external ethernet as single port.
* Assign it a static or DHCP IP address.

### Storage

* Create 2 small partitions `50GB` at the beginning of each disk. Raid 1 them together and set the mountpoint to `/` with `ext4`.
* Create 2 large partitions with the rest of the disks. Do not format them.

### Deploy the machine

with a recent ubuntu

## On Machine

### Storage pool

We use `btrfs` for the container storage, as it works well with nested containers. The drawbacks are reduced quota control, which is not a factor in our setting.

As raid members, use the 2 large partitions of the disks (probably `/dev/sd?2` or `/dev/sd?3` (if EFI partition available)).

```
mkfs.btrfs -L lxd -d raid1 /dev/sda? /dev/sdb?
```

The filesystem can be verified by any of the participating partitions
```
btrfs filesystem show /dev/sda?
```

Create mount directory
```
mkdir /media/pool
```

and append a line in `etc/fstab`
```
/dev/sda?  /media/pool  btrfs user_subvol_rm_allowed 0 0
```

and mount the fs with `mount /media/pool`

### snap

Uninstall the `apt` lxd version
```
sudo apt-get remove --purge lxd lxd-client
```

Install the stable channel from snap. This is a more frequently updated stable release instead of the apt version, which only receives security bug fixes.
```bash
snap install lxd
```

### Kernel Keyring size

As the kernel keyring is not namespaced, it needs to be large enough:

Add `kernel.keys.maxkeys = 5000` to `/etc/sysctl.conf` and apply it with `sysctl -p`


### Time
For the distributed database to work, all nodes have to be in sync regarding time. Therefore install 
```bash
apt-get install ntp
```


## prepare lxd

Set up the cluster master run `sudo lxd init`, here vs-node5 as example.



```
sudo lxd init
Would you like to use LXD clustering? (yes/no) [default=no]: 
Do you want to configure a new storage pool? (yes/no) [default=yes]: 
Name of the new storage pool [default=default]: 
Name of the storage backend to use (btrfs, ceph, dir, lvm, zfs) [default=zfs]: btrfs
Create a new BTRFS pool? (yes/no) [default=yes]: no
Name of the existing BTRFS pool or dataset: /media/pool
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=lxdbr0]: lxdintern
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
Would you like LXD to be available over the network? (yes/no) [default=no]: yes
Address to bind LXD to (not including port) [default=all]: 
Port to bind LXD to [default=8443]: 
Trust password for new clients: 
Again: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes] 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]: yes
config:
  core.https_address: '[::]:8443'
  core.trust_password: ****
networks:
- config:
    ipv4.address: auto
    ipv6.address: none
  description: ""
  managed: false
  name: lxdintern
  type: ""
storage_pools:
- config:
    source: /media/pool
  description: ""
  name: default
  driver: btrfs
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdintern
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
cluster: null
```

You can check if the cluster is set up correctly with `lxc cluster list`

### Profile

Add devices to the default profile `lxc profile edit default`

```
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: lxdintern
    type: nic
  eth1:
    name: eth1
    nictype: bridged
    parent: lxdextern
    type: nic
  root:
    path: /
    pool: local
    type: disk

```

The `lxdintern` bridge must be attached to eth0, as the DHCP will query on this interface. This assures that the containers do not query for a DHCP IP on the bridged external bridge, but only fetch an IPv6 through this bridge. 

### Test

You can create a test container with 
```
lxc launch ubuntu:18.04 test
```

and check it with `lxc list`

## Adding the host to the managment

authenticate with a superuser to the api

### Subnet
add the subnet the host resides in.

### Host

add a new host with a name, subnet and url as well as the trust pw.



## Troubleshooting

### Permission denied to mount

`/media/pool/containers` needs 711 permissions

### Adding host fails

Set the LXD_CA_CERT environment variable to false, if your lxd-host uses a self signed certificate.