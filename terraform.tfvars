# Hetzner Cloud API Token
# REPLACE THIS with your actual token
hcloud_token = "replace_with_your_actual_token_here"

# Server Configuration
server_name     = "control"
server_image    = "fedora-40"
server_location = "nbg1"    # Nuremberg
server_type     = "ccx23"   # 4 vCPU, 16 GB RAM

# SSH Keys
# Make sure this key name exists in your Hetzner Cloud Console
ssh_keys = ["key1"]

# Firewall Configuration
# "0.0.0.0/0" allows SSH from ANY IP.
# For better security, replace with your specific IP: ["1.2.3.4/32"]
firewall_source_ip = "0.0.0.0"

# SSH Port
# Default is 22. Change this if you change the SSH port on the server.
ssh_port = "22"

