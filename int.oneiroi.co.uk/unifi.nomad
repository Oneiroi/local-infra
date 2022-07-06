job "unifi" {
  datacenters = ["DC1"]
  type = "system"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "unifi" {
    network {
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
        image = "linuxserver/unifi-controller:latest"
        ports = [
          "3478",
          "5114",
          "6789",
          "8080",
          "8880",
          "8443",
          "10001",
        ]
        volumes  = [
          "/media/nvem/unifi/config:/config",
        ]
      }
    }
  }
}
