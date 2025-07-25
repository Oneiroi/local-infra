job "cloudflared" {
  datacenters = ["DC1"]
  type        = "service"

  meta {
    image_version = "2025.6.1" # When modifying this is also needs to be updated in the config section below
  }

  constraint {    
    attribute       = "${attr.kernel.name}"
    value           = "linux"
  }
  
  spread {
     attribute = "${node.unique.name}"
  }

  group "cloudflared" {
    count = 3
    scaling {
      enabled = true
      min     = 3
      max     = 4
    }
    spread {
      attribute = "${node.unique.name}"

      target "internet-pi.int.oneiroi.co.uk" {
        percent = 33
      }

      target "internet-pi2.int.oneiroi.co.uk" {
        percent = 33
      }

      target "internet-pi5.int.oneiroi.co.uk" {
        percent = 33
      }

    }
    volume "cloudflared" {
        type        = "host"
        source      = "cloudflared"
        read_only   = false
    }
    update {
      max_parallel      = 0
      min_healthy_time  = "10s"
      healthy_deadline  = "1m"
      progress_deadline = "5m"
      auto_revert       = true
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
        image = "crazymax/cloudflared:2025.6.1"
        ports = [
          "doh",
          "argometrics"
        ]
        #cap_drop = ["all"]
        #cap_add  = []
        readonly_rootfs = true
      }
    }
    service {
      check {
        name = "cloudflared_up"
        type = "tcp"
        port = "doh"
        interval = "10s"
        timeout = "1s"
      }
      check_restart {
        limit = 3
        grace = "90s"
        ignore_warnings = false
      }
    }  
  }
}
