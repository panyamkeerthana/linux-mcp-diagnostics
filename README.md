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

## VM Automation (Optional)

This project integrates with [mcp-vm-scripts](https://github.com/owtaylor/mcp-vm-scripts) to automatically create VMs and run scenario playbooks for testing troubleshooting scenarios in isolated environments.

### Installation

Install mcp-vm-scripts by following the instructions at [GitHub repository](https://github.com/owtaylor/mcp-vm-scripts).

Once installed, you can create a VM and automatically run a scenario playbook:

```bash
./tools/mcpvm setup --playbook=<path to linux-mcp-diagnostics>/scenarios/04_systemd_oom_limit/scenario.yaml --version=10.1
```

This command will:
1. Create a new RHEL VM
2. Configure it with SSH access
3. Run the specified scenario playbook to introduce the failure

For managing VMs

```bash
# List all managed VMs
./tools/mcpvm list

# Delete a VM when done
./tools/mcpvm delete <vm-name>
```

For detailed setup instructions, VM management commands, and platform-specific requirements, see the mcp-vm-scripts documentation.

## Scenarios

Scenarios are triggered using Ansible tags that introduce a specific system failure.

| Scenario | Tag | Command | Failure Description |
|----------|-----|---------|---------------------|
| **SELinux Port Denial** | `scenario1` | `ansible-playbook -i hosts.ini scenarios/01_selinux_port_denial/scenario.yaml -K` | Apache configured on port 8088, blocked by SELinux policy |
| **SSH Permission Lockdown** | `scenario2` | `ansible-playbook -i hosts.ini scenarios/02_ssh_permissions/scenario.yaml -K` | `.ssh` directory set to `0777`, blocking key-based auth |
| **OOM Kill** | `scenario4` | `ansible-playbook -i hosts.ini scenarios/04_systemd_oom_limit/scenario.yaml -K` | `chronyd` service constrained to 1MB memory, triggers OOM |
| **Cascading Failure** | `scenario5` | `ansible-playbook -i hosts.ini scenarios/05_cascading_db_failure/scenario.yaml -K` | MariaDB disk full + broken log directory ownership |

## Evaluation with Rubric-Kit

This project integrates with [rubric-kit](https://github.com/narmaku/rubric-kit) to create evaluation rubrics for evaluating mcp server performance. Rubric-kit provides assessment of how AI agents handle these failure scenarios.


### Installation

```bash
pip install rubric-kit
```

For detailed installation and setup instructions, see the [rubric-kit documentation](https://github.com/narmaku/rubric-kit).

### Usage

#### Generate a Rubric from a Chat Session

```bash
rubric-kit generate --from-chat-session scenarios/01_selinux_port_denial/<chat-session-file.txt> \
  --output-file scenarios/01_selinux_port_denial/rubric.yaml \
  --model gemini/gemini-2.5-flash
```

#### Evaluate a Chat Session Against a Rubric

```bash
rubric-kit evaluate --from-chat-session <chat-session-file.txt> \
  --rubric-file scenarios/01_selinux_port_denial/rubric.yaml \
  --output-file results.yaml
```

#### Export Results to PDF

```bash
rubric-kit export results.yaml --format pdf --output report.pdf
```

For more information on rubric structure, judge panels, and evaluation options, see the [rubric-kit repository](https://github.com/narmaku/rubric-kit).

