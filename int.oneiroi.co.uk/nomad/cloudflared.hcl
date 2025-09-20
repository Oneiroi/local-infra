job "cloudflared" {
  datacenters = ["DC1"]
  type        = "service"

  meta {
    image_version = "2025.9.0" # When modifying this is also needs to be updated in the config section below
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
      max_parallel      = 1 
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
        image = "cloudflare/cloudflared:2025.9.0"
        args = [
          "proxy-dns",
          "--address", "0.0.0.0",
          "--port", "5053",
          "--upstream", "https://1.1.1.1/dns-query",
          "--upstream", "https://1.0.0.1/dns-query",
          "--metrics", "0.0.0.0:49312"
        ]
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
