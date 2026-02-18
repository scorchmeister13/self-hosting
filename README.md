# Self-Hosting Infrastructure

Ansible-based setup for self-hosting services on Debian nodes with Docker and Traefik.

## Repository Structure

```
.
├── files/
│   ├── docker-compose/          # Docker Compose files for each application
│   │   ├── traefik/
│   │   ├── immich/
│   │   ├── vaultwarden/
│   │   └── ...
│   ├── docker/                   # Docker daemon configuration
│   └── dns/                      # DNS configuration files
├── group_vars/all/               # Global variables (defaults_*.yml)
├── host_vars/                    # Host-specific overrides
├── roles/
│   ├── setup-node/               # Node standardization role
│   ├── setup-step/               # Step CA certificate authority role
│   └── docker-deploy/            # Docker application deployment role
├── setup-node.yml                # Initial node setup playbook
├── setup-step.yml                # Step CA setup playbook
└── setup-docker-application.yml  # Application deployment playbook
```

## Quick Start

1. **Install dependencies:**
   ```bash
   ansible-galaxy collection install -r collections/requirements.yml
   ```

2. **Configure inventory** (`inventory.ini`) with your hosts

3. **Run the playbooks in order:**
   ```bash
   # Initial node setup (DNS, users, packages, Docker)
   ansible-playbook -i inventory.ini setup-node.yml

   # Setup Step CA for SSL certificates
   ansible-playbook -i inventory.ini setup-step.yml

   # Deploy applications (interactive - prompts for app name)
   ansible-playbook -i inventory.ini setup-docker-application.yml
   ```

## How the Playbooks Work

### `setup-node.yml`

Standardizes and configures new nodes. The `setup-node` role handles:
- DNS configuration
- User management
- Package installation
- Docker installation and configuration
- Time synchronization
- SSH hardening
- Optional: Tailscale VPN, drive mounting

Run this first on any new node to get it ready for services.

### `setup-step.yml`

Installs and configures Step CA for automatic SSL certificate management. Sets up:
- Step CLI tools
- Step CA server (when `step_is_server: true`)
- Bootstrap configuration for certificate enrollment

### `setup-docker-application.yml`

Deploys Docker applications interactively. When you run it, you'll be prompted to enter an application name (e.g., `traefik`, `immich`, `vaultwarden`).

The `docker-deploy` role follows this flow:

1. **`00_docker.yml`** - Ensures Docker is installed (runs for all apps)
2. **App-specific subtasks** - Conditional tasks for apps that need extra setup
3. **`xx_docker_deploy.yml`** - Common deployment steps (copy compose file, create network, deploy)

#### Creating Subtasks for Special Configurations

Some applications need extra files or configuration beyond the standard `docker-compose.yaml`. The playbook handles this with conditional subtask files.

**Example: Immich deployment**

Immich needs a `.env` file with database credentials and API keys. The playbook includes `02_immich.yml` which runs only when `application_target == "immich"`:

```yaml
# roles/docker-deploy/tasks/02_immich.yml
- name: Ensure Immich folder exists
  ansible.builtin.file:
    path: /opt/stacks/{{ application_target }}/
    state: directory

- name: Copy over Immich .env file
  ansible.builtin.template:
    src: "files/docker/{{ application_target }}/.env.j2"
    dest: "/opt/stacks/{{ application_target }}/.env"
```

This subtask is included in `main.yml` with a condition:
```yaml
- name: 02_immich.yml
  ansible.builtin.include_tasks: "02_immich.yml"
  when: application_target == "immich"
```

**To add a new app with special config:**

1. Create a subtask file: `roles/docker-deploy/tasks/XX_appname.yml`
2. Add the conditional include in `roles/docker-deploy/tasks/main.yml`:
   ```yaml
   - name: XX_appname.yml
     ansible.builtin.include_tasks: "XX_appname.yml"
     when: application_target == "appname"
   ```

Other examples:
- **gethomepage** (`03_gethomepage.yml`) - Copies multiple config files (services.yaml, docker.yaml, settings.yaml, widgets.yaml) and images
- **traefik** (`01_traefik.yml`) - Handles Traefik-specific setup

## Configuration

### Docker Compose Files

All application compose files live in `files/docker-compose/<app-name>/docker-compose.yaml`. These are templated with Ansible variables (like `{{ domain }}`) and copied to `/opt/stacks/<app-name>/` on the target host.

### Variables

- **Global defaults:** `group_vars/all/defaults*.yml` - Settings for all hosts
- **Host overrides:** `host_vars/<hostname>.yml` - Per-host customization
- **Common variables:**
  - `domain` - Your domain name
  - `timezone` - System timezone
  - App-specific vars in `defaults_<app>.yml` files

### Example: Changing Domain

Edit `group_vars/all/defaults.yml`:
```yaml
domain: yourdomain.com
timezone: "America/New_York"
```

## Common Commands

```bash
# Setup a specific node
ansible-playbook -i inventory.ini setup-node.yml --limit node01.example.com

# Deploy an app to a specific node
ansible-playbook -i inventory.ini setup-docker-application.yml --limit node01.example.com

# When using encrypted variables (Ansible Vault), add --ask-vault-pass
ansible-playbook -i inventory.ini setup-docker-application.yml --limit node01.example.com --ask-vault-pass

# Check running containers
ansible all -i inventory.ini -m shell -a "docker ps" --become
```

## Notes

- Applications deploy to `/opt/stacks/<application>/`
- Traefik uses the `proxy` Docker network for automatic service discovery
- All configs are managed by Ansible (see `ansible.cfg`)
- Sensitive data should be stored in Ansible Vault
