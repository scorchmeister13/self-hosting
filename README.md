# Self-Hosting

Ansible-based infrastructure for self-hosting services on Debian nodes with Docker and Traefik.

## Prerequisites

- Ansible installed on your control machine
- SSH access to target hosts
- Python 3 on target hosts
- Ansible collections (install with `ansible-galaxy collection install -r collections/requirements.yml`)

## Quick Start

### 1. Configure Inventory

Edit `inventory.ini` to match your hosts:

```ini
[hosts]
your-host.example.com    ansible_host=192.168.1.50

[vms]
node01.example.com   ansible_host=192.168.1.51
```

### 2. Setup Node (Initial Configuration)

Standardize and configure nodes (DNS, users, packages, Docker, etc.):

```bash
ansible-playbook -i inventory.ini setup-node.yml
```

### 3. Setup Step CA (Certificate Authority)

Install and configure Step CA for SSL certificates:

```bash
ansible-playbook -i inventory.ini setup-step.yml
```

### 4. Deploy Applications

Deploy Docker applications interactively:

```bash
ansible-playbook -i inventory.ini setup-docker-application.yml
```

When prompted, enter one of:
- `traefik` - Reverse proxy with automatic SSL
- `immich` - Photo and video management
- `gethomepage` - Homepage dashboard
- `homepage` - Update homepage configuration
- `adguard` - DNS ad-blocker
- `vaultwarden` - Password manager

## Customization

### Application Configuration

Edit variables in `group_vars/all/defaults_*.yml`:
- `defaults_traefik.yml` - Traefik settings
- `defaults_immich.yml` - Immich database and API keys
- `defaults_vaultwarden.yml` - Vaultwarden settings
- `defaults.yml` - Global settings (domain, timezone, etc.)

### Host-Specific Configuration

Override settings per host in `host_vars/<hostname>.yml`.

### Docker Compose Files

Modify application configurations in `files/docker-compose/<application>/docker-compose.yaml`.

### Example: Change Domain

Edit `group_vars/all/defaults.yml`:
```yaml
domain: yourdomain.com
timezone: "America/New_York"
```

## Commands

```bash
# Setup new node
ansible-playbook -i inventory.ini setup-node.yml --limit node01.example.com

# Deploy specific application
ansible-playbook -i inventory.ini setup-docker-application.yml --limit node01.example.com

# Check status
ansible all -i inventory.ini -m shell -a "docker ps" --become
```

## Notes

- All configuration files are managed by Ansible (see `ansible.cfg`)
- Sensitive data is stored in Ansible Vault (encrypted)
- Applications are deployed to `/opt/stacks/<application>/`
- Traefik uses the `proxy` Docker network for service discovery
