job "pi-hole" {
  datacenters = ["DC1"]
  type = "service"
  
  meta {
    image_version = "2025.07.1" # When modifying this is also needs to be updated in the config section below
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

  group "pi-hole" {
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
      target "internet-pi3.int.oneiroi.co.uk" {
        percent = 33
      }
    }
    volume "pihole" {
        type        = "host"
        source      = "pihole"
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
        #cap_drop = ["ALL"]
        #cap_add  = ["CAP_CHOWN","CAP_NET_BIND_SERVICE"]
        #docker pull pihole/pihole:2024.01.0
        image = "pihole/pihole:2025.07.1"
        force_pull = true
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
        ]
      }
    }
    service {
      check {
        name      = "pihole_http"
        type      = "http"
        path      = "/admin/login.php"
        interval  = "10s"
        timeout   = "2s"
        port      = "8081"
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
