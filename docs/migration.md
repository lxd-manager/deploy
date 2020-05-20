# Migrations

Providing seamless upgrades and migration to a new system is always preferable.


## Import from any lxd instance

The LXD daemons support copying of containers between each other.

### Conenct lxd instances

Therefore add one of your new hosts to the remotes of the old host, such that it is listed in 

    lxc remote ls

as e.g. new-lxd

### Preprare containers

While the container is still running on the old host:

#### Extract the ssh host keys
To preserve the ssh host keys and keep the fingerprint:

    host$ lxc exec <ctname> bash
    
    container$ for i in /etc/ssh/ssh_host_*; do echo $i; cat $i; echo ''; done
    
Keep the output of the loop in a safe place, as they can be used to impersonate the container

#### Remove Profiles
If your container has profiles apart from the default profile, remove them by

    lxc config edit <ctname>
    
#### Stop container

Live migration of containers is possible, but not recommended. 
    
    lxc stop <ctname>
    
### Copy Container

    lxc copy <ctname> new-lxd:

### Integration

#### Host Keys
Wait until the background synchronisation registered the new container. Once you know the ID, go to
https://your-manager.tld/api/container/<ID>/import_keys/
where you can paste the output of the host keys command.
This allows to use the same host keys as before, but they are now managed by the application.

#### Project
Assign the container to a project to grant access to non-admin users at https://your-manager.tld/api/container/<ID>/ 

You may then redeploy the keys to fully integrate the instance into lxd-manager.

#### IPs
If your container possessed special IPs, please add then through the UI and restart your container. 