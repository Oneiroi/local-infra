#TODO

Currently nomad throws "port exhaustion" errors given the required allocations of service jobs and static ports, this leads to issues with upgrades.

Implement https://github.com/katakonst/go-dns-proxy fronting each pi-hole instance dns service,e.g.

docker run -p 53:53/udp katakonst/go-dns-proxy:latest -use-outbound -json-config='{
    "defaultDns": "192.168.X.${i}:53",
    "servers": {
        "pi-hole$i" : "192.168.X.$i:53"
    },
    "domains": {
        "test.com" : "8.8.8.8"
    }
}'

Additionally this needs to also front the cloudflared service between pihole and cloudflared

## improvement work

implement proxy per node, which has all the static ports asssigned to it.

Have this proxy front all requests to the backened service containers.


