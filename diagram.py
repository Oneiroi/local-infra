from diagrams import Cluster, Diagram, Edge
from diagrams.custom import Custom
from diagrams.oci.compute import Container


with Diagram("Internal infra over engineered nightmare, send scotch!"):
    usg = Custom("usg-3p", "icons/usg3p.png")
    ap  = Custom("UAP-AC-PRO - Living Room", "icons/UAP-AC-PRO.png")
    aps = Custom("UAP-AC-PRO - Storage Space", "icons/UAP-AC-PRO.png")

    
    with Cluster("internet-pi.int.oneiroi.co.uk - NOMAD"):
        cf_argo = Custom("cloudflared", "icons/cf-logo-v-rgb.png")
        pihole  = Custom("pi.hole", "icons/pihole.png")
        unifi   = Custom("unifi", "icons/unifi.png")

    with Cluster("internet-pi2.int.oneiroi.co.uk - NOMAD"):
        cf_argo2 = Custom("cloudflared", "icons/cf-logo-v-rgb.png")
        pihole2  = Custom("pi.hole2", "icons/pihole.png")
        #unifi   = Custom("unifi")

    usg >> Edge(label="Ubiquiti management") >> unifi
    unifi >> Edge(label="Ubiquiti management") >> usg

    ap >> Edge(label="Ubiquiti management") >> unifi
    unifi >> Edge(label="Ubiquiti management") >> ap

    aps >> Edge(label="Ubiquiti management") >> unifi
    unifi >> Edge(label="Ubiquiti management") >> aps 
    
    ap >> usg << ap

    pihole >> Edge(label="DNS") >> pihole2
    pihole2 >> Edge(label="DNS over HTTPS") >> cf_argo2
    pihole2 << Edge(label="DNS over HTTPS") << cf_argo2

    pihole2 >> Edge(label="DNS") >> pihole >> Edge(label="DNS over HTTPS") >> cf_argo
    pihole << Edge(label="DNS over HTTPS") << cf_argo
    

