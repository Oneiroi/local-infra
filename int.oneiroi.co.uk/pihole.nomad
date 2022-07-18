job "pi-hole" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "pi-hole" {
    volume "pihole" {
        type        = "host"
        source      = "pihole"
        read_only   = false
    }
    update {
     max_parallel      = 2 
     min_healthy_time  = "10s"
     healthy_deadline  = "1m"
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
      volume_mount {
          volume      = "pihole"
          destination = "/etc/pihole"
      }
      driver = "docker"
      config {        
        image = "pihole/pihole:latest"
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
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
