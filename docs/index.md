# LXD manager
The lxd-manager is a management software which is used to orchestrate multiple hosts of lxd containers with a specific deep integration. It was built with very specific demands, but might be useful to someone else.

We needed lighweight containers on different kinds of hosts, which behave like physical maschines. Unfortunately with inhomogenious hosts, the lxd built in cluster is not reliable and we barely rely on cluster feature, as most often we want control over where a container is deployed.

On top, each container is attached with two network interfaces.

- eth0 is connected to a bridge of the host and gets an IPv4 NATed address
- eth1 is bridged directly to the hosts interface and obtains a SLAAC IPv6 address. If required, users can assign IPv4 addresses to this interface through our api.

The service contains an authoritative DNS server for all containers which are reachable publicly.

Another useful feature is the integration with gitlab not only for user authentication but also for direct provisioning of ssh keys from the user's gitlab profile.

Unlike many lxd web UIs, this software uses its own database for persistance and has a background synchronisation service, as live polling of the lxd api is too slow. Actions are usually displayed responsive and then performed in a background task.