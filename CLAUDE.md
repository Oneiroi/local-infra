# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ Critical Operating Principles

**DEPLOYMENT POLICY:**
- **NEVER** execute deployment commands (`tofu apply`, `nomad job run`, etc.) automatically
- **ALWAYS** provide the user with the exact commands to run
- **USER IS RESPONSIBLE** for all deployments and infrastructure changes
- Claude's role is to prepare, document, and guide - NOT to execute deployments
- All automation scripts must require explicit user confirmation before making remote changes

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
├── nomad/                  # Nomad job specifications
│   ├── pihole.hcl         # Pi-hole DNS service (3 replicas)
│   ├── cloudflared.hcl    # Cloudflare tunnel/DNS-over-HTTPS
│   ├── unifi.hcl          # Unifi network controller
│   ├── homeassistant.hcl  # Home Assistant
│   ├── n8n.hcl           # n8n automation platform
│   ├── vault.hcl         # HashiCorp Vault
│   ├── victron.hcl       # Victron energy monitoring
│   └── twingate.hcl      # Twingate secure network connector
└── n8n/                   # n8n workflow configurations
    ├── infrastructure_monitor_workflow.json  # Main monitoring workflow
    ├── discord_approval_bot.py              # Discord approval bot
    ├── test_components.sh                   # Component testing script
    ├── README.md                            # Detailed documentation
    ├── ARCHITECTURE.md                      # Architecture details
    └── QUICKSTART.md                        # Quick start guide
```

## Common Commands

**Environment Setup**: Set your Nomad cluster address:
```bash
export NOMAD_ADDR=http://<your-nomad-server>:4646
```

### OpenTofu Operations
```bash
cd int.oneiroi.co.uk/
tofu init
tofu plan
tofu apply
tofu destroy
```

**Note**: This project uses OpenTofu instead of legacy Terraform. The Nomad provider is configured to use `$NOMAD_ADDR`.

### Nomad Job Management
Access Nomad UI at: `$NOMAD_ADDR` (via Twingate tunnel)

Direct job operations (if needed):
```bash
nomad job run nomad/pihole.hcl
nomad job status pi-hole
nomad job stop pi-hole
```

**Note**: Ensure `NOMAD_ADDR` environment variable is set for all Nomad CLI operations since DNS resolution requires Twingate connectivity.

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

## Infrastructure Monitoring

The `n8n/` directory contains an automated infrastructure monitoring workflow that provides:

- **Comprehensive Health Checks**: Network connectivity, Nomad cluster status, Pi-hole, and Cloudflared services
- **LLM-Based Analysis**: Local Ollama (gemma2:9b) for intelligent issue detection and recommendations
- **Human-in-the-Loop**: Discord webhook notifications with approval workflow for remediation actions
- **Automated Remediation**: SSH-based service restarts and fixes (with required human approval)

### Key Components

- `infrastructure_monitor_workflow.json` - n8n workflow (runs every 5 minutes)
- `discord_approval_bot.py` - Discord bot for easy approval/rejection via reactions
- `test_components.sh` - Comprehensive component testing script

### Quick Setup

```bash
cd int.oneiroi.co.uk/n8n/

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Discord webhook and bot token

# Test all components
./test_components.sh

# Import workflow into n8n and start the Discord bot
python3 discord_approval_bot.py
```

See `n8n/README.md` for detailed setup instructions and `n8n/QUICKSTART.md` for step-by-step guidance.

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
   nomad var put -namespace=default nomad/jobs/twingate \
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