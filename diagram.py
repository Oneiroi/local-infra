from diagrams import Cluster, Diagram, Edge
from diagrams.custom import Custom
from diagrams.oci.compute import Container


with Diagram("Internal infra Diagram as Code"):
    usg = Custom("usg-3p", "icons/usg3p.png")
    ap  = Custom("UAP-AC-PRO - Living Room", "icons/UAP-AC-PRO.png")
    aps = Custom("UAP-AC-PRO - Storage Space", "icons/UAP-AC-PRO.png")

    
    with Cluster("internet-pi.int.oneiroi.co.uk - NOMAD"):
        cf_argo = Custom("cloudflared", "icons/cf-logo-v-rgb.png")
        pihole  = Custom("pi.hole", "icons/pihole.png")
        unifi   = Custom("unifi-controller", "icons/unifi.png")

    with Cluster("internet-pi2.int.oneiroi.co.uk - NOMAD"):
        cf_argo2 = Custom("cloudflared2", "icons/cf-logo-v-rgb.png")
        pihole2  = Custom("pi.hole2", "icons/pihole.png")
        #unifi   = Custom("unifi")

    with Cluster("internet-pi3.int.oneiroi.co.uk - NOMAD"):
        cf_argo3 = Custom("cloudflared3", "icons/cf-logo-v-rgb.png")
        pihole3  = Custom("pi.hole3", "icons/pihole.png")
        #unifi   = Custom("unifi")

    #usg connection to unfi controller, bi-driectional, cfg management and reporting
    usg >> unifi >> usg

    #unifi controller to AP management, bi-directional, cfg management and reporting
    ap >> unifi >> ap
    aps >> unifi >> aps

    #Traffic flow AP to USG 
    ap >> usg << aps

    #pihole1 DNSoH query to cf_argo{..3}
    pihole >> Edge(label="DNS over HTTPS") >> cf_argo
    pihole >> Edge(label="DNS over HTTPS") >> cf_argo2
    pihole >> Edge(label="DNS over HTTPS") >> cf_argo3
     
    #pihole2 DNSoH query to cf_argo{..3}
    pihole2 >> Edge(label="DNS over HTTPS") >> cf_argo
    pihole2 >> Edge(label="DNS over HTTPS") >> cf_argo2
    pihole2 >> Edge(label="DNS over HTTPS") >> cf_argo3

    #pihole3 DNSoH query to cf_argo{..3}
    pihole3 >> Edge(label="DNS over HTTPS") >> cf_argo
    pihole3 >> Edge(label="DNS over HTTPS") >> cf_argo2
    pihole3 >> Edge(label="DNS over HTTPS") >> cf_argo3
