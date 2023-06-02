#TODO

Currently nomad throws "port exhaustion" errors given the required allocations of service jobs and static ports, this leads to issues with upgrades.


## improvement work

implement proxy per node, which has all the static ports asssigned to it.

Have this proxy front all requests to the backened service containers.


