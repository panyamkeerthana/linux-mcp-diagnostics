# Linux MCP Troubleshooting Scenarios

This repository contains the Ansible playbook to support [rhel-lightspeed/linux-mcp-server](https://github.com/rhel-lightspeed/linux-mcp-server).

The purpose of this work is to create reproducible broken system states that can be used to benchmark and compare different AI-driven troubleshooting strategies.

## Prerequisites

- **Ansible** installed locally
- A **RHEL** virtual machine with SSH access
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

Scenarios are triggered using Ansible tags that introduce a specific system failure.

| Scenario | Tag | Command | Failure Description |
|----------|-----|---------|---------------------|
| **SELinux Port Denial** | `scenario1` | `ansible-playbook -i hosts.ini 01_selinux_port_denial -K` | Apache configured on port 8088, blocked by SELinux policy |
| **SSH Permission Lockdown** | `scenario2` | `ansible-playbook -i hosts.ini 02_ssh_permissions.yaml -K` | `.ssh` directory set to `0777`, blocking key-based auth |
| **OOM Kill** | `scenario4` | `ansible-playbook -i hosts.ini 04_systemd_oom_limit.yaml -K` | `chronyd` service constrained to 1MB memory, triggers OOM |
| **Cascading Failure** | `scenario5` | `ansible-playbook -i hosts.ini 05_cascading_db_failure.yaml --tags scenario5 -K` | MariaDB disk full + broken log directory ownership |

