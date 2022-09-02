job "pi-hole" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"
    distinct_hosts = true 
  }

  group "pi-hole1" {
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
        image = "pihole/pihole:2022.08.3"
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
        ]
      }
    }
  }
  group "pi-hole2" {
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
        image = "pihole/pihole:2022.08.3"
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
