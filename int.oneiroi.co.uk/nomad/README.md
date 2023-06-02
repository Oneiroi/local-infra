#TODO

Currently nomad throws "port exhaustion" errors given the required allocations of service jobs and static ports, this leads to issues with upgrades.

##workaround

1. nomad job stop $name
2. confirm job stopped and containers removed
3. nomad job run $name.nomad

## improvement work

implement an openresty web proxy per node, which has all the static ports asssigned to it.

Have this proxy front all requests to the backened service containers.


