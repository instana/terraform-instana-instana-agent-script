# ==============================================================================
# Outputs
# ==============================================================================
#
# All outputs are marked sensitive because the rendered script contains
# the baked-in Instana agent key.
#
# Linux usage:
#   AWS  : user_data    = module.instana_agent_script.linux_agent_bootstrap
#   GCP  : metadata     = { startup-script = module.instana_agent_script.linux_agent_bootstrap }
#   Azure: custom_data  = module.instana_agent_script.linux_agent_bootstrap_base64
#
# Windows usage:
#   AWS  : user_data    = module.instana_agent_script.windows_agent_bootstrap
#   GCP  : metadata     = { windows-startup-script-ps1 = module.instana_agent_script.windows_agent_bootstrap }
#   Azure: custom_data  = module.instana_agent_script.windows_agent_bootstrap_base64
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Linux outputs
# ------------------------------------------------------------------------------

output "linux_agent_bootstrap" {
  description = <<-EOT
    Rendered Linux bootstrap shell script (plain text).
    Use as user_data (AWS) or the startup-script metadata value (GCP).
  EOT
  value       = local.linux_agent_bootstrap
  sensitive   = true
}

output "linux_agent_bootstrap_base64" {
  description = <<-EOT
    Rendered Linux bootstrap shell script, base64-encoded.
    Use as custom_data for Azure Linux VMs.
  EOT
  value       = local.linux_agent_bootstrap_base64
  sensitive   = true
}

# ------------------------------------------------------------------------------
# Windows outputs
# ------------------------------------------------------------------------------

output "windows_agent_bootstrap" {
  description = <<-EOT
    Rendered Windows PowerShell bootstrap script (plain text).
    Use as user_data (AWS Windows) or the windows-startup-script-ps1 metadata value (GCP).
  EOT
  value       = local.windows_agent_bootstrap
  sensitive   = true
}

output "windows_agent_bootstrap_base64" {
  description = <<-EOT
    Rendered Windows PowerShell bootstrap script, base64-encoded.
    Use as custom_data for Azure Windows VMs.
  EOT
  value       = local.windows_agent_bootstrap_base64
  sensitive   = true
}
