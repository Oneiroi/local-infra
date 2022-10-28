job "pi-hole" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  #constraint {
  #  operator = "distinct_hosts"
  #  value    = "true"
  #}

  spread {
     attribute = "${node.unique.name}"
  }

  group "pi-hole" {
    count = 2
    volume "pihole" {
        type        = "host"
        source      = "pihole"
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
      volume_mount {
          volume      = "pihole"
          destination = "/etc/pihole"
      }
      driver = "docker"
      config {        
        image = "pihole/pihole:2022.10"
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
        ]
      }
    }
  }
}
