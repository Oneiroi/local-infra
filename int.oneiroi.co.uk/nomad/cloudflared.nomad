job "cloudflared" {
  datacenters = ["DC1"]
  type        = "service"
  
  constraint {    
    attribute      = "${attr.kernel.name}"
    value          = "linux"
  }

  spread {
     attribute = "${node.unique.name}"
  }

  group "cloudflared" {
    count = 2
    volume "cloudflared" {
        type        = "host"
        source      = "cloudflared"
        read_only   = false
    }
    update {
     max_parallel      = 1
     canary            = 1
     min_healthy_time  = "10s"
     healthy_deadline  = "1m"
     progress_deadline = "5m"
     auto_revert       = true
     auto_promote      = true
     stagger           = "1m"
    }
    network {
      port "doh" {
        static       = 5053
        to           = 5053
      }
      port "argometrics" {
        static = "49312"
        to     = "49312"
      }
         
    }
    task "server" {
      volume_mount {
          volume      = "cloudflared"
          destination = "/var/log"
        }
      driver = "docker"
      config {        
        image = "crazymax/cloudflared:2022.12.1"
        ports = [
          "doh",
          "argometrics"
        ]
        cap_drop = ["all"]
        cap_add  = []
        readonly_rootfs = true
      }
    }
  }
}
