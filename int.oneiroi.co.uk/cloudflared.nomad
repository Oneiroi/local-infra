job "cloudflared" {
  datacenters = ["DC1"]
  type = "service"
  
  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"  
  }

  group "cloudflared" {
    network {
      port "doh" {
        static       = 5053
        to           = 5053
      }
      port "argometrics" {
        static = "49312"
        to     = "49312"
      }
         
    }
    task "server" {
      driver = "docker"
      config {        
        image = "crazymax/cloudflared:latest"
        ports = [
          "doh",
          "argometrics"
        ]
        volumes  = [
          "/media/nvem/cloudflare/var/log:/var/log",
        ]
      }
    }
  }
}
