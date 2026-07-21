# terraform-instana-agent-script

A cloud-agnostic Terraform module that renders an Instana agent bootstrap script for Linux VMs.
Call it once, then pass the output directly to your existing AWS, GCP, or Azure VM resource — no
cloud-specific agent module required.

## Features

- **Zero providers** — pure data module; uses only built-in Terraform functions (`templatefile`,
  `base64encode`, `coalesce`).
- **Dual-distro** — supports Debian/Ubuntu (`apt`) and Amazon Linux (`yum`).
- **Optional download key** — falls back to `instana_agent_key` when `instana_download_key` is not
  provided.
- **Custom configuration** — pass raw YAML via `custom_config_yaml`; it is appended to the agent's
  `configuration.yaml` after installation.
- **Two output variants** — plain text for AWS/GCP, base64-encoded for Azure.

## Usage

```hcl
module "instana_agent_script" {
  source = "git::https://github.com/your-org/terraform-instana-agent-script.git"

  instana_agent_key     = var.instana_agent_key
  instana_endpoint_host = "ingress-pink-saas.instana.rocks"
}
```

### AWS — `user_data`

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id

  user_data = module.instana_agent_script.linux_agent_bootstrap
}
```

### GCP — `startup-script` metadata

```hcl
resource "google_compute_instance" "app" {
  name         = "app-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params { image = "debian-cloud/debian-12" }
  }

  network_interface { network = "default" }

  metadata = {
    startup-script = module.instana_agent_script.linux_agent_bootstrap
  }
}
```

### Azure — `custom_data`

```hcl
resource "azurerm_linux_virtual_machine" "app" {
  name                = "app-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.main.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = module.instana_agent_script.linux_agent_bootstrap_base64
}
```

### With custom agent configuration

```hcl
module "instana_agent_script" {
  source = "git::https://github.com/your-org/terraform-instana-agent-script.git"

  instana_agent_key     = var.instana_agent_key
  instana_endpoint_host = "ingress-pink-saas.instana.rocks"

  custom_config_yaml = file("${path.module}/instana-config.yaml")
}
```

## Input Variables

| Name | Type | Required | Default | Description |
|------|------|:--------:|---------|-------------|
| `instana_agent_key` | `string` | ✅ | — | Instana agent key for backend authentication. |
| `instana_endpoint_host` | `string` | ✅ | — | Instana backend endpoint host (e.g. `ingress-pink-saas.instana.rocks`). |
| `instana_download_key` | `string` | | `null` | Instana download key. Defaults to `instana_agent_key` when omitted. |
| `instana_endpoint_port` | `number` | | `443` | Instana backend port (1–65535). |
| `instana_agent_mode` | `string` | | `"dynamic"` | Agent mode. One of: `APM`, `INFRASTRUCTURE`, `AWS`, `KUBERNETES`, `dynamic`. |
| `agent_max_memory` | `number` | | `544` | Agent heap memory in MB (512–8192). Increase for large environments. |
| `custom_config_yaml` | `string` | | `null` | Raw YAML string appended to `configuration.yaml` after agent installation. |

## Outputs

Both outputs are `sensitive = true` because they contain the baked-in agent key.

| Name | Description | Cloud usage |
|------|-------------|-------------|
| `linux_agent_bootstrap` | Rendered bootstrap script (plain text). | AWS `user_data`, GCP `startup-script` metadata |
| `linux_agent_bootstrap_base64` | Rendered bootstrap script, base64-encoded. | Azure `custom_data` |

## Supported Linux Distributions

| Distribution | Package manager |
|---|---|
| Debian 11 / 12 | `apt-get` |
| Ubuntu 20.04 / 22.04 / 24.04 | `apt-get` |
| Amazon Linux 2 / 2023 | `yum` |

## Requirements

| Tool | Version |
|------|---------|
| Terraform | `>= 1.3.0` |

No Terraform provider is required by this module.

## Examples

See [`examples/basic/`](examples/basic/) for a complete example showing all three cloud providers.

## Installation log

The bootstrap script logs to `/var/log/instana-agent-install.log` on the VM.

```bash
# Check agent status
sudo systemctl status instana-agent

# View agent runtime logs
sudo tail -f /opt/instana/agent/data/log/agent.log

# View install log
sudo cat /var/log/instana-agent-install.log
```
