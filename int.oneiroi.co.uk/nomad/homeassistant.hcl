job "cloudflared" {
  datacenters = ["DC1"]
  type        = "service"

  meta {
    image_version = "homeassistant/home-assistant:2025.7"
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  affinity {
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
    weight    = 100
  }

  group "homeassist" {
    count = 1

    update {
      max_parallel      = 0
      min_healthy_time  = "10s"
      healthy_deadline  = "1m"
      progress_deadline = "5m"
      auto_revert       = true
    }

    network {
      port "homeassist" {
        static   = 8123
        to       = 8123
        
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "homeassistant/home-assistant:2025.7"
        ports = [
          "homeassist",
        ]
        #readonly_rootfs = true
        network_mode = "host"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }

    service {
      check {
        name     = "homeassist_up"
        type     = "tcp"
        port     = "homeassist"
        interval = "10s"
        timeout  = "1s"
      }

      check_restart {
        limit           = 3
        grace           = "90s"
        ignore_warnings = false
      }
    }
  }
}
