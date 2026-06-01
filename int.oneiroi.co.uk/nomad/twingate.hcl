job "twingate" {
  datacenters = ["DC1"]
  type        = "service"

  meta {
    image_version = "1.88.0"
    deployment_trigger = "2026-05-26-upgrade-to-1.88.0"
  }

  constraint {    
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }
  
  constraint {
    attribute = "${node.class}"
    operator  = "!="
    value     = "AI"
  }

  group "twingate" {
    count = 1

    update {
      max_parallel      = 1
      min_healthy_time  = "10s"
      healthy_deadline  = "1m"
      progress_deadline = "5m"
      auto_revert       = true
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "connector" {
      driver = "docker"

      config {
        image = "twingate/connector:1.88.0"
      }
      
      template {
        data = <<EOF
TWINGATE_ACCESS_TOKEN="{{ with nomadVar "nomad/jobs/twingate" }}{{ .twingate_access_token }}{{ end }}"
TWINGATE_REFRESH_TOKEN="{{ with nomadVar "nomad/jobs/twingate" }}{{ .twingate_refresh_token }}{{ end }}"
TWINGATE_NETWORK="{{ with nomadVar "nomad/jobs/twingate" }}{{ .twingate_network }}{{ end }}"
EOF
        destination = "local/twingate.env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }

    service {
      name = "twingate-connector"
      task = "connector"
      
      check_restart {
        limit = 3
        grace = "90s"
        ignore_warnings = false
      }
    }
  }
}
