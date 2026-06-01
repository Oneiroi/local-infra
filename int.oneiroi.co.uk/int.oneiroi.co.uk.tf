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

resource "nomad_job" "mongodb_unifi" {
    jobspec = file("${path.module}/nomad/mongodb-unifi.hcl")
}

resource "nomad_job" "unifi_network_application" {
    jobspec    = file("${path.module}/nomad/unifi-network-application.hcl")
    depends_on = [nomad_job.mongodb_unifi]
}

resource "nomad_job" "twingate" {
    jobspec = file("${path.module}/nomad/twingate.hcl")
}

resource "nomad_job" "twingate_orin_super" {
    jobspec = file("${path.module}/nomad/twingate-orin-super.hcl")
}

resource "nomad_job" "n8n" {
    jobspec = file("${path.module}/nomad/n8n.hcl")
}

# Ollama runs natively on Orin Super host (not containerized)
# - Uses native NVIDIA GPU access
# - Custom model storage path on NVMe: /media/nvme/ollama/models
# - Not managed via Nomad/Terraform
# - See ollama.hcl for reference containerized config (not deployed)

resource "nomad_job" "caddy" {
    jobspec = file("${path.module}/nomad/caddy.hcl")
}

resource "nomad_job" "caddy_orin_super" {
    jobspec = file("${path.module}/nomad/caddy-orin-super.hcl")
}

resource "nomad_job" "homeassistant" {
    jobspec = file("${path.module}/nomad/homeassistant.hcl")
}

resource "nomad_job" "postgres_immich" {
    jobspec = file("${path.module}/nomad/postgres-immich.hcl")
}

resource "nomad_job" "redis_immich" {
    jobspec = file("${path.module}/nomad/redis-immich.hcl")
}

resource "nomad_job" "immich" {
    jobspec    = file("${path.module}/nomad/immich.hcl")
    depends_on = [nomad_job.postgres_immich, nomad_job.redis_immich]
}

resource "nomad_job" "cloudflare_tunnel" {
    jobspec = file("${path.module}/nomad/cloudflare-tunnel.hcl")
}

# Ask Dad Services - AI conversational system
# Phase 1: Infrastructure components (ChromaDB, Whisper, Piper)

resource "nomad_job" "chromadb" {
    jobspec = file("${path.module}/nomad/ask-dad/chromadb.hcl")
}

resource "nomad_job" "whisper" {
    jobspec    = file("${path.module}/nomad/ask-dad/whisper.hcl")
    depends_on = [nomad_job.chromadb]
}

resource "nomad_job" "piper" {
    jobspec    = file("${path.module}/nomad/ask-dad/piper.hcl")
    depends_on = [nomad_job.chromadb]
}

# Phase 3: Main API service (depends on all infrastructure components)
resource "nomad_job" "ask_dad_api" {
    jobspec    = file("${path.module}/nomad/ask-dad/ask-dad-api.hcl")
    depends_on = [nomad_job.chromadb, nomad_job.whisper, nomad_job.piper]
}

# NAS cluster for centralized backup storage
module "nas_cluster" {
    source = "./nas-cluster"
}

