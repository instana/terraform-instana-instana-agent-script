# ==============================================================================
# Outputs
# ==============================================================================
#
# Both outputs are marked sensitive because the rendered script contains
# the baked-in Instana agent key.
#
# Usage:
#   AWS  : user_data    = module.instana_agent_script.linux_agent_bootstrap
#   GCP  : metadata     = { startup-script = module.instana_agent_script.linux_agent_bootstrap }
#   Azure: custom_data  = module.instana_agent_script.linux_agent_bootstrap_base64
#
# ==============================================================================

output "linux_agent_bootstrap" {
  description = <<-EOT
    Rendered bootstrap shell script (plain text).
    Use as user_data (AWS) or the startup-script metadata value (GCP).
  EOT
  value     = local.linux_agent_bootstrap
  sensitive = true
}

output "linux_agent_bootstrap_base64" {
  description = <<-EOT
    Rendered bootstrap shell script, base64-encoded.
    Use as custom_data (Azure).
  EOT
  value     = local.linux_agent_bootstrap_base64
  sensitive = true
}
