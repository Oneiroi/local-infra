job "unifi" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }
  constraint {
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
  }
  affinity{
    #Unifi gear uses set-inform to connect equipment to the controller useually on a fixed ip
    #We want this job to always deploy to the primary node as a result
    attribute = "${node.unique.name}"
    value     = "internet-pi.int.oneiroi.co.uk"
    weight    = 100
  }

  group "unifi" {
    count = 2
    #Volume stanza to access the host volume for data storage and persistance
    volume "unifi" {
        type        = "host"
        source      = "unifi"
        read_only   = false
    }
    #Update stanza to enable rolling updates of the service
    update {
     max_parallel      = 2
     canary            = 1 
     min_healthy_time  = "10s"
     healthy_deadline  = "3m"
     progress_deadline = "10m"
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
        image = "linuxserver/unifi-controller:7.5.187"
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
        #attribute = "${node.unique.name}"
        attribute = "${node.unique.id}"
        value     = "82b9781e-e552-aea5-16fe-7efa84e87371"
        #value     = "internet-pi.int.oneiroi.co.uk"
        weight    = 100
      }
      #This block is not currently functional, leads to dead job or being placed on another node
      #service {
      #  check {
      #    name = "unifi_up"
      #    type = "http"
      #    port = "https"
      #    path = "/manage"
      #    interval = "60s"
      #  }
      #    timeout = "60s"
      #  check_restart {
      #    limit = 3
      #    grace = "90s"
      #    ignore_warnings = false
      #  }
      #}
    }
  }
}
