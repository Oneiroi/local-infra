# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a home infrastructure-as-code repository using HashiCorp Nomad for container orchestration on Raspberry Pi devices. The project manages home network services including Pi-hole (DNS), Cloudflared (DNS-over-HTTPS), Unifi Controller, and other services across multiple Pi nodes.

## Architecture

### Core Components
- **OpenTofu**: Manages Nomad job deployments via the Nomad provider
- **Nomad Jobs**: HCL job specifications for containerized services
- **Multi-node Setup**: 3 main Raspberry Pi nodes (internet-pi, internet-pi2, internet-pi3) plus one AI node

### Directory Structure
```
int.oneiroi.co.uk/
├── int.oneiroi.co.uk.tf    # Main OpenTofu configuration
└── nomad/                  # Nomad job specifications
    ├── pihole.hcl         # Pi-hole DNS service (3 replicas)
    ├── cloudflared.hcl    # Cloudflare tunnel/DNS-over-HTTPS
    ├── unifi.hcl          # Unifi network controller
    ├── homeassistant.hcl  # Home Assistant
    ├── n8n.hcl           # n8n automation
    ├── vault.hcl         # HashiCorp Vault
    ├── victron.hcl       # Victron energy monitoring
    └── twingate.hcl      # Twingate secure network connector
```

## Common Commands

### OpenTofu Operations
```bash
cd int.oneiroi.co.uk/
tofu init
tofu plan
tofu apply
tofu destroy
```

**Note**: This project uses OpenTofu instead of legacy Terraform. The Nomad provider is configured to use `http://192.168.83.6:4646`.

### Nomad Job Management
Access Nomad UI at: `http://192.168.83.6:4646` (via Twingate tunnel)

Direct job operations (if needed):
```bash
NOMAD_ADDR=http://192.168.83.6:4646 nomad job run nomad/pihole.hcl
NOMAD_ADDR=http://192.168.83.6:4646 nomad job status pi-hole
NOMAD_ADDR=http://192.168.83.6:4646 nomad job stop pi-hole
```

**Note**: Use `NOMAD_ADDR=http://192.168.83.6:4646` for all Nomad CLI operations since DNS resolution requires Twingate connectivity.

### Diagram Generation
Generate infrastructure diagram:
```bash
python diagram.py
```

## Key Architectural Patterns

### Service Deployment Strategy
- Services use `spread` scheduling across 3 main nodes
- Rolling updates with `max_parallel = 0` for zero-downtime deployments
- Auto-revert enabled for failed deployments
- Host volumes for persistent data

### Network Configuration
- Static port assignments for services (potential port exhaustion issue noted)
- Pi-hole runs on port 53 (DNS), 8081 (HTTP), 443 (HTTPS), 67 (DHCP)
- Services spread across nodes with 33% allocation per node

### Known Issues
- Port exhaustion during upgrades due to static port requirements
- Rolling replacement strategy needs DNS proxy implementation (see nomad/README.md)

## Development Notes

### Image Version Management
When updating container images, version must be updated in two places:
1. `meta.image_version` block
2. `config.image` field in the task

### Constraints
- AI node excluded from most services with `node.class != "AI"` constraint
- Linux-only deployments
- Distinct host spreading for high availability

### Volume Mounts
Services requiring persistence use host volumes (e.g., Pi-hole configuration)

## Twingate Connector Setup

The Twingate connector provides secure network access to the home lab infrastructure.

### Implementation Steps

1. **Create Nomad Job Definition** (`nomad/twingate.hcl`):
   - Uses `twingate/connector:1` image
   - Single instance deployment
   - Excludes AI nodes with constraint
   - Environment variables sourced from Nomad variables via template stanza

2. **Set Required Nomad Variables**:
   ```bash
   NOMAD_ADDR=http://192.168.83.6:4646 nomad var put -namespace=default nomad/jobs/twingate \
     twingate_access_token="your_access_token" \
     twingate_refresh_token="your_refresh_token" \
     twingate_network="your_network_name"
   ```

3. **Deploy via OpenTofu**:
   ```bash
   cd int.oneiroi.co.uk/
   tofu apply -target=nomad_job.twingate
   ```

### Key Configuration Details

- **Environment Variables**: Uses template stanza with `nomadVar` function to access variables from `nomad/jobs/twingate` path
- **Health Checks**: Removed script-based health check due to process detection issues; relies on Nomad's built-in container health monitoring
- **Resource Allocation**: 100 MHz CPU, 128 MiB memory
- **Status Monitoring**: Check connector status with `nomad alloc logs <allocation_id>` - should show "State: Online" when working