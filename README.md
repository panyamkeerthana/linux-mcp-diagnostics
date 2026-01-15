# Linux MCP Troubleshooting Reproducible Scenarios

This repository contains Ansible playbooks to support the [rhel-lightspeed/linux-mcp-server](https://github.com/rhel-lightspeed/linux-mcp-server) project.

The purpose of this work is to create **reproducible broken system states** that can be used to benchmark and compare different AI-driven troubleshooting strategies.

## Prerequisites

- **Ansible** installed locally
- A **RHEL/CentOS/Fedora** virtual machine with SSH access
- Snapshot capability for your VM (QEMU or similar)

### Install Ansible

```bash
# macOS
brew install ansible

# Fedora/RHEL
sudo dnf install ansible

# Ubuntu/Debian
sudo apt install ansible
```

## Setup

### 1. Configure Inventory

Copy the inventory template and configure your VM connection:

```bash
cp hosts.ini.example hosts.ini
```


## Scenarios

Scenarios are triggered using Ansible tags. Each tag introduces a specific system failure.

| Scenario | Tag | Command | Failure Description |
|----------|-----|---------|---------------------|
| **SELinux Port Denial** | `scenario1` | `ansible-playbook -i hosts.ini troubleshooting_scenarios.yml --tags scenario1 -K` | Apache configured on port 8088, blocked by SELinux policy |
| **SSH Permission Lockdown** | `scenario2` | `ansible-playbook -i hosts.ini troubleshooting_scenarios.yml --tags scenario2 -K` | `.ssh` directory set to `0777`, blocking key-based auth |
| **OOM Kill** | `scenario4` | `ansible-playbook -i hosts.ini troubleshooting_scenarios.yml --tags scenario4 -K` | `chronyd` service constrained to 1MB memory, triggers OOM |
| **Cascading Failure** | `scenario5` | `ansible-playbook -i hosts.ini troubleshooting_scenarios.yml --tags scenario5 -K` | MariaDB disk full + broken log directory ownership |

