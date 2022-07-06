job "pi-hole" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "pi-hole" {
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
      driver = "docker"
      config {        
        image = "pihole/pihole:latest"
        ports = [
          "dns",
          "dhcp",
          "http",
          "https"
        ]
        volumes  = [
          "/media/nvem/pihole/etc/:/etc/pihole/",
          "/media/nvem/pihole/etc/dnsmasq.d/etc-dnsmasq.d/:/etc/dnsmasq.d/",
          "/media/nvem/pihole/var/log/pihole.log:/var/log/pihole.log",
        ]
      }
    }
  }
}
