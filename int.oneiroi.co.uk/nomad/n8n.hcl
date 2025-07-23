job "n8n" {
  datacenters = ["DC1"]
  type = "service"

  meta {
    image_version = "1.103.1"
  }

  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  constraint {
    attribute = "node.class"
    value     = "AI"
    operator  = "!="
  }

  spread {
    attribute = "${node.unique.name}"
  }

  group "n8n" {
    count = 1

    spread {
      attribute = "${node.unique.name}"
      target "internet-pi.int.oneiroi.co.uk" {
        percent = 33
      }
      target "internet-pi2.int.oneiroi.co.uk" {
        percent = 33
      }
      target "internet-pi3.int.oneiroi.co.uk" {
        percent = 33
      }
    }

    update {
      max_parallel      = 1            # rolling update, one at a time
      min_healthy_time  = "10s"
      healthy_deadline  = "1m"
      progress_deadline = "5m"
      auto_revert       = true
    }

    network {
      port "n8n" {
        static = 5678
        to     = 5678
      }
    }

    task "server" {
      constraint {
        attribute = "node.unique.name"
        value     = "ai.int.oneiroi.co.uk"
        operator  = "!="
      }

      driver = "docker"

      config {
        image = "n8nio/n8n:1.103.1"
        ports = ["n8n"]

        volumes = [
          "n8n_data:/home/node/.n8n"
        ]
      }

      resources {
        cpu    = 2000
        memory = 1024
      }
    }

    service {
      name = "n8n-service"
      port = "n8n"

      check {
        name     = "n8n_http"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
        port     = "n8n"
      }
    }
  }
}
