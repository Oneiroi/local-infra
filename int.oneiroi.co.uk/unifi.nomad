job "unifi" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "unifi" {
    volume "unifi" {
        type        = "host"
        source      = "unifi"
        read_only   = false
    }
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
        to           = 8080
      }
      port "httpsredir"{
        static       = 8843
        to           = 8843
      }
      port "speedtest" {
        static       = 6789
        to           = 6789
      }
      port "stun" {
        static       = 3478
        to           = 3478
      }
      port "servicedisc" {
        static       = 10001
        to           = 10001
      }
      port "l2disc" {
        static      = 1900
        to          = 1900
      }
    }
    task "server" {
      volume_mount {
          volume      = "unifi"
          destination = "/config"
          read_only   = false
      }
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
      }
      affinity {
        attribute = "${node.datacenter}"
        value = "internet-pi.int.oneiroi.co.uk.global"
      }
    }
    scaling {
      enabled = true
      min = 1
      max = 1
    }
  }
}
