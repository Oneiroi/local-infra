job "homeassistant" {
  datacenters = ["DC1"]
  type        = "service"

  meta {
    image_version = "2025.12.5"
  }

  # Deploy on Orin Super (AI node) - better resources for HA
  constraint {
    attribute = "${node.class}"
    value     = "AI"
  }

  group "homeassistant" {
    count = 1

    # Host volume for Home Assistant configuration persistence
    volume "homeassistant-config" {
      type      = "host"
      source    = "homeassistant-config"
      read_only = false
    }

    update {
      max_parallel      = 0
      min_healthy_time  = "10s"
      healthy_deadline  = "3m"
      progress_deadline = "10m"
      auto_revert       = true
    }

    network {
      port "http" {
        static = 8123
        to     = 8123
      }
    }

    task "homeassistant" {
      driver = "docker"

      volume_mount {
        volume      = "homeassistant-config"
        destination = "/config"
        read_only   = false
      }

      config {
        image = "homeassistant/home-assistant:2025.12.5"
        ports = ["http"]

        # Host network mode required for device discovery
        network_mode = "host"

        # Required system mounts
        volumes = [
          "/run/dbus:/run/dbus:ro",
          "/etc/machine-id:/etc/machine-id:ro"
        ]

        # Privileged mode may be needed for USB devices
        privileged = true
      }

      env {
        TZ = "UTC"
      }

      resources {
        cpu    = 2000  # More CPU on Orin Super
        memory = 1024  # More memory for integrations and GeekMagic devices
      }
    }

    service {
      name = "homeassistant"
      port = "http"

      tags = [
        "homeassistant",
        "home-automation"
      ]

      check {
        name     = "homeassistant_http"
        type     = "http"
        port     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }

      check_restart {
        limit           = 3
        grace           = "90s"
        ignore_warnings = false
      }
    }
  }
}
