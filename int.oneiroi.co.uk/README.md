# Local Infrastructure - int.oneiroi.co.uk

This directory contains the Infrastructure-as-Code (IaC) configuration for managing home network services using HashiCorp Nomad on Raspberry Pi devices.

## What's Inside

### Nomad Job Specifications (`nomad/`)
Nomad job files for containerized services including:
- **Pi-hole** - DNS ad-blocking (3 replicas)
- **Cloudflared** - DNS-over-HTTPS tunnel
- **Unifi Controller** - Network management
- **Home Assistant** - Home automation
- **n8n** - Workflow automation platform
- **Vault** - Secrets management
- **Victron** - Energy monitoring
- **Twingate** - Secure network connector

### Infrastructure Monitoring (`n8n/`)
Automated infrastructure monitoring workflow with:
- Comprehensive health checks for all services
- LLM-based intelligent analysis (Ollama + gemma2:9b)
- Discord notifications with human-in-the-loop approval
- Automated remediation capabilities

See `n8n/README.md` for detailed monitoring setup.

### OpenTofu Configuration
- `int.oneiroi.co.uk.tf` - Main OpenTofu configuration managing Nomad jobs

## Quick Start

```bash
# Deploy infrastructure
cd int.oneiroi.co.uk/
tofu init
tofu apply

# Set up monitoring
cd n8n/
./test_components.sh
```

## Architecture

- **3 Main Nodes**: Raspberry Pi devices (server + client roles)
- **1 AI Node**: Dedicated AI workload node (client-only)
- **Deployment**: Services spread across nodes for high availability
- **Updates**: Rolling updates with auto-revert on failure

## Learning & Experimentation

This serves as an IaC sandbox for learning Nomad and managing home infrastructure. Expect ongoing refinements and improvements as knowledge grows.

See `CLAUDE.md` for detailed guidance and architecture documentation.
