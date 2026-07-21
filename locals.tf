# ==============================================================================
# Local Values
# ==============================================================================

locals {
  # Fall back to agent key when download key is not explicitly provided.
  effective_download_key = coalesce(var.instana_download_key, var.instana_agent_key)

  # Base64-encode the custom YAML config for safe embedding in the shell script.
  # Empty string signals the script template to skip the append block.
  custom_config_yaml_base64 = var.custom_config_yaml != null ? base64encode(var.custom_config_yaml) : ""

  # Render the bootstrap script with all variables resolved.
  linux_agent_bootstrap = templatefile("${path.module}/templates/linux_agent_bootstrap.sh.tftpl", {
    instana_agent_key        = var.instana_agent_key
    instana_download_key     = local.effective_download_key
    instana_endpoint_host    = var.instana_endpoint_host
    instana_endpoint_port    = var.instana_endpoint_port
    instana_agent_mode       = var.instana_agent_mode
    agent_max_memory         = var.agent_max_memory
    custom_config_yaml_base64 = local.custom_config_yaml_base64
  })

  # Base64-encoded variant required by Azure custom_data.
  linux_agent_bootstrap_base64 = base64encode(local.linux_agent_bootstrap)
}
