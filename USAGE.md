# Cloud Boxes - Usage Guide

This guide covers how to configure, provision, and manage your cloud server.

## 1. Initial Setup

### Prerequisites
- **Terraform** installed
- **Ansible** installed
- **Hetzner Cloud API Token** (Read & Write permissions)
- **SSH Key** added to your Hetzner Cloud account

### Configuration
We use `terraform.tfvars` to manage sensitive and custom configuration.

1. **Create the variables file:**
   Copy the example or create a new `terraform.tfvars` in the root directory.

2. **Edit `terraform.tfvars`:**
   ```hcl
   # Hetzner Token
   hcloud_token = "your-token-here"

   # SSH Key Name (must match Hetzner Console)
   ssh_keys = ["your-key-name"]

   # Server Specs
   server_type = "ccx23" # 4 vCPU, 16GB RAM
   server_name = "control"

   # SSH Port (Default: 22)
   ssh_port = "22"

   # Security: Limit SSH access to your IP (Recommended)
   # firewall_source_ip = "1.2.3.4"
   # OR allow all IPs (if you have dynamic IP):
   firewall_source_ip = "0.0.0.0"
   ```

## 2. Changing the SSH Port

To use a non-standard SSH port (e.g., 2222) for better security:

### Step A: Update Terraform
In `terraform.tfvars`:
```hcl
ssh_port = "2222"
```
*This opens the port in the Hetzner Cloud Firewall.*

### Step B: Update Ansible
In `vars.yml`:
```yaml
ssh_port: 2222
```
*This configures the server software (SSHD), SELinux, and local firewall to use the new port.*

## 3. Provisioning Infrastructure (Terraform)

1. **Initialize:**
   ```bash
   terraform init
   ```

2. **Apply Changes:**
   ```bash
   terraform apply
   ```
   *Review the plan and type `yes`.*

3. **Note the IP Address:**
   Terraform will output the `control_public_ip4`.

## 4. Configuring the Server (Ansible)

Once the server is running, use Ansible to configure it.

### Step A: Update Inventory
Edit the `hosts` file with your server's IP:
```ini
[hetzner]
<SERVER_IP> ansible_ssh_private_key_file=~/.ssh/id_ed25519 ssh_public_key_file=~/.ssh/id_ed25519.pub
```

### Step B: Security Hardening (Run Once)
This playbook creates the `build` user, sets up keys, changes the SSH port (if configured), and disables root login.

**First run (uses port 22):**
```bash
ansible-playbook -i hosts --limit=hetzner init-ssh.yml
```

**Note:** If you changed the SSH port in `vars.yml`, the connection will close during this run. This is normal. Future connections must use the new port.

### Step C: Install Software (Docker, Tools)
Now deploy the software stack.

**If using standard port 22:**
```bash
ansible-playbook -i hosts --limit=hetzner playbook.yml
```

**If using a custom port (e.g., 2222):**
Update your `hosts` file to specify the port:
```ini
[hetzner]
<SERVER_IP>:2222 ansible_ssh_private_key_file=...
```
Or pass it as a flag:
```bash
ansible-playbook -i hosts --limit=hetzner playbook.yml --private-key ~/.ssh/id_ed25519 --ssh-common-args='-p 2222'
```

