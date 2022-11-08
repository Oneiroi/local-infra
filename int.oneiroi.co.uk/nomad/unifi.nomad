job "unifi" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }
  affinity{
    #Unifi gear uses set-inform to connect equipment to the controller useually on a fixed ip
    #We want this job to always deploy to the primary node as a result
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
    weight    = 100
  }

  group "unifi" {
    volume "unifi" {
        type        = "host"
        source      = "unifi"
        read_only   = false
    }
    update {
     max_parallel      = 1
     canary            = 1 
     min_healthy_time  = "10s"
     healthy_deadline  = "1m"
     progress_deadline = "15m"
     auto_revert       = true
     auto_promote      = true
     stagger           = "1m"
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
        image = "linuxserver/unifi-controller:7.2.95"
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
        attribute = "${node.unique.name}"
        value     = "internet-pi.int.oneiroi.co.uk"
        weight    = 100
      }
    }
    scaling {
      enabled = true
      min = 1
      max = 1
    }
  }
}
