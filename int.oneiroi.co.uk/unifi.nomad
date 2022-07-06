job "unifi" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "unifi" {
    #https://help.ui.com/hc/en-us/articles/218506997-UniFi-Network-Required-Ports-Reference
    network {
      port "http" {
        static       = 8080
        to           = 8080
      }
      port "https" {
        static       = 8443
        to           = 8443
      }
      port "httpredir"{
        static       = 8880
      }
      port "httpsredir"{
        static       = 8843
      }
      port "speedtest" {
        static       = 6789
      }
      port "stun" {
        static       = 3478
      }
      port "servicedisc" {
        static       = 10001
      }
      port "l2disc" {
        static      = 1900
      }
    }
    task "server" {
      driver = "docker"
      config {        
        image = "linuxserver/unifi-controller:latest"
        ports = [
          "http",
          "https",
          "httpredir",
          "httpsredir",
          "speedtest",
          "stun",
          "servicedisc",
          "l2disc"
        ]
        volumes  = [
          "/media/nvem/unifi/config:/config",
        ]
      }
    }
  }
}
