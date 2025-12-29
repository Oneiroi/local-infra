job "pihole" {
  datacenters = ["DC1"]
  type = "service"
  
  meta {
    image_version = "2025.11.1" # When modifying this is also needs to be updated in the config section below
    deployment_trigger = "2025-12-01-2156" # Use Caddy proxy for health checks
  }

  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }
  constraint {
    attribute = "node.class"
    value = "AI"
    operator = "!="
  }

  #constraint {
  #  operator = "distinct_hosts"
  #  value    = "true"
  #}

  spread {
     attribute = "${node.unique.name}"
  }

  group "pihole" {
    count = 3
    #spread the allocations across the 3 main nodes, negating the fourth node (as we only want 3 allocations total active when not upgrading)
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
    volume "pihole" {
        type        = "host"
        source      = "pihole"
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
      port "dhcp" {
	      static       = 67
        to           = 67
      }
      port "dns" {
        static       = 53
        to           = 53
      }
      port "http" {
        static       = 8081
        to           = 80
      }
      port "https" {
        static       = 443
        to           = 443
      }
    }
    task "server" {
      constraint {
        attribute = "node.unique.name"
        value     = "ai.int.oneiroi.co.uk"
        operator  = "!="
      }
      volume_mount {
          volume      = "pihole"
          destination = "/etc/pihole"
      }
      driver = "docker"
      config {
        name = "pihole"
        #cap_drop = ["ALL"]
        #cap_add  = ["CAP_CHOWN","CAP_NET_BIND_SERVICE"]
        #docker pull pihole/pihole:2024.01.0
        image = "pihole/pihole:2025.11.1"
        force_pull = true
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
        ]
      }

      # Configure Pi-hole to use Unbound as upstream DNS
      # Port 5335 to avoid conflict with Avahi mDNS on 5353
      env {
        PIHOLE_DNS_ = "127.0.0.1#5335"
      }
    }
    service {
      name = "pihole"
      port = "http"

      check {
        name     = "pihole_http"
        type     = "http"
        path     = "/admin/login"
        interval = "10s"
        timeout  = "2s"
        port     = 80
        header {
          Host = ["pihole.${node.unique.name}"]
        }
      }
    }
    #service {
      #check {
      #  name = "pihole_up"
      #  type = "http"
      #  port = "http"
      #  path = "/"
      #  interval = "10s"
      #  timeout = "1s"
      #}
      #check_restart {
      #  limit = 3
      #  grace = "90s"
      #  ignore_warnings = false
      #}
    #}
  }
}
