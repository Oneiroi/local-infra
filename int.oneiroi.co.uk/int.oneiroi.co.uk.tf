provider "nomad" {
    address = "http://192.168.83.6:4646"
}

resource "nomad_job" "pihole" {
    jobspec = file("${path.module}/nomad/pihole.hcl")
}

resource "nomad_job" "cloudflared" {
    jobspec = file("${path.module}/nomad/cloudflared.hcl")
}

resource "nomad_job" "unifi" {
    jobspec = file("${path.module}/nomad/unifi.hcl")
}

resource "nomad_job" "twingate" {
    jobspec = file("${path.module}/nomad/twingate.hcl")
}

resource "nomad_job" "n8n" {
    jobspec = file("${path.module}/nomad/n8n.hcl")
}

resource "nomad_job" "ollama" {
    jobspec = file("${path.module}/nomad/ollama.hcl")
}

resource "nomad_job" "caddy" {
    jobspec = file("${path.module}/nomad/caddy.hcl")
}

resource "nomad_job" "homeassistant" {
    jobspec = file("${path.module}/nomad/homeassistant.hcl")
}

