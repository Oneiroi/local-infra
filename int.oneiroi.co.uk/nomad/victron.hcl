job "victron-influx-loader" {
  datacenters = ["DC1"]
  type        = "service"
  
  constraint {    
    attribute       = "${attr.kernel.name}"
    value           = "linux"
  }
  constraint {
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
  }
  affinity{
    #Unifi gear uses set-inform to connect equipment to the controller useually on a fixed ip
    #We want this job to always deploy to the primary node as a result
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
    weight    = 100
  }

  group "victron-influx-loader" {
    count = 1
    volume "victron-influx-loader" {
        type        = "host"
        source      = "victron-influx-loader"
        read_only   = false
    }
    update {
     max_parallel      = 1
     canary            = 3
     min_healthy_time  = "10s"
     healthy_deadline  = "1m"
     progress_deadline = "5m"
     auto_revert       = true
     auto_promote      = true
     stagger           = "1m"
    }
    network {
      port "http" {
        static       = 8088
        to           = 8088
      }
    }
    task "server" {
      volume_mount {
          volume      = "victron-influx-loader"
          destination = "/config"
        }
      driver = "docker"
      config {        
        image = "victronenergy/venus-influx-loader:1.0.0"
        ports = [
          "http"
        ]
        #cap_drop = ["all"]
        #cap_add  = []
        readonly_rootfs = true
      }
    }  
  }
}
