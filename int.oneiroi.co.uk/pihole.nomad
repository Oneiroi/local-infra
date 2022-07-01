job "pi-hole" {
  datacenters = ["homelab"]
  type = "system"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  constraint {    
    attribute = "${node.class}"    
    value     = "raspberry-pi"  
  }

  group "pi-hole" {
    network {
      mode = "bridge"
      port "dhcp" {
	static       = 67
        to           = 67
        host_network = "tailscale"
      }
      port "dns" {
        static       = 53
        to           = 53
        host_network = "tailscale"
      }
      port "http" {
        static       = 8080
        to           = 80
        host_network = "tailscale"
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
        ]
        volumes  = [
          "/media/nvem/pihole/etc/:/etc/pihole/",
          "/media/nvem/pihole/etc/dnsmasq.d/etc-dnsmasq.d/:/etc/dnsmasq.d/",
          "/edia/nvem/pihole/var/log/pihole.log:/var/log/pihole.log",
        ]
        cap_add = ["net_admin", "setfcap"]
      }
    }
  }
}
