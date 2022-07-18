job "cloudflared" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "cloudflared" {
    volume "cloudflared" {
        type        = "host"
        source      = "cloudflared"
        read_only   = false
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
        image = "crazymax/cloudflared:latest"
        ports = [
          "doh",
          "argometrics"
        ]
      }
    }
    scaling {
      enabled = true
      min = 2
      max = 2
    }
  }
}
