# ==============================================================================
# Basic Example — terraform-instana-agent-script
# ==============================================================================
#
# This example shows how to call the instana-agent-script module and wire its
# outputs into AWS, GCP, and Azure VM resources.
#
# Only one cloud section is needed in practice — the stubs below are shown
# together purely for illustration.
# ==============================================================================

terraform {
  required_version = ">= 1.3.0"
}

# ------------------------------------------------------------------------------
# 1. Render the bootstrap script (no provider required for this module)
# ------------------------------------------------------------------------------

module "instana_agent_script" {
  source = "../../"

  # Required
  instana_agent_key     = var.instana_agent_key
  instana_endpoint_host = var.instana_endpoint_host

  # Optional — defaults to instana_agent_key when omitted
  # instana_download_key = var.instana_download_key

  # Optional — defaults shown
  instana_endpoint_port = 443
  instana_agent_mode    = "dynamic"
  agent_max_memory      = 544

  # Optional — raw YAML appended to configuration.yaml after install
  # custom_config_yaml = file("${path.module}/instana-custom-config.yaml")
}

# ------------------------------------------------------------------------------
# 2a. AWS — pass plain-text script as user_data
# ------------------------------------------------------------------------------
#
# resource "aws_instance" "my_vm" {
#   ami           = "ami-0abcdef1234567890"
#   instance_type = "t3.medium"
#   subnet_id     = var.subnet_id
#
#   user_data = module.instana_agent_script.linux_agent_bootstrap
# }

# ------------------------------------------------------------------------------
# 2b. GCP — pass plain-text script as startup-script metadata
# ------------------------------------------------------------------------------
#
# resource "google_compute_instance" "my_vm" {
#   name         = "my-vm"
#   machine_type = "e2-medium"
#   zone         = "us-central1-a"
#
#   boot_disk {
#     initialize_params { image = "debian-cloud/debian-12" }
#   }
#
#   network_interface { network = "default" }
#
#   metadata = {
#     startup-script = module.instana_agent_script.linux_agent_bootstrap
#   }
# }

# ------------------------------------------------------------------------------
# 2c. Azure — pass base64-encoded script as custom_data
# ------------------------------------------------------------------------------
#
# resource "azurerm_linux_virtual_machine" "my_vm" {
#   name                = "my-vm"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   size                = "Standard_D2s_v3"
#   admin_username      = "azureuser"
#
#   network_interface_ids = [azurerm_network_interface.main.id]
#
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }
#
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }
#
#   custom_data = module.instana_agent_script.linux_agent_bootstrap_base64
# }
