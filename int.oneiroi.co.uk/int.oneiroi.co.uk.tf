provider "nomad" {
    address = "https://internet-pi.int.oneiroi.co.uk:4646"
}

resource "nomad_job" "pi-hole" {
    jobspec = file("${path.module}/nomad/pihole.nomad")
}

resource "nomad_job" "cloudflared" {
    jobspec = file("${path.module}/nomad/cloudflared.nomad")
}

resource "nomad_job" "unifi" {
    jobspec = file("${path.module}/nomad/unifi.nomad")
}
