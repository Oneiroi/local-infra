provider "nomad" {
    address = "http://192.168.83.6:4646"
}

resource "nomad_job" "pi-hole" {
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

