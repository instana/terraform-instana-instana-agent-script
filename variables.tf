# ==============================================================================
# Required Variables
# ==============================================================================

variable "instana_agent_key" {
  description = "Instana agent key for authentication with the Instana backend."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.instana_agent_key) > 0
    error_message = "instana_agent_key cannot be empty."
  }
}

variable "instana_endpoint_host" {
  description = "Instana backend endpoint host (e.g. ingress-pink-saas.instana.rocks)."
  type        = string

  validation {
    condition     = length(var.instana_endpoint_host) > 0
    error_message = "instana_endpoint_host cannot be empty."
  }
}

# ==============================================================================
# Optional Variables
# ==============================================================================

variable "instana_download_key" {
  description = <<-EOT
    Instana download key used to fetch the agent package.
    When not provided, the module falls back to instana_agent_key.
  EOT
  type        = string
  sensitive   = true
  default     = null
}

variable "instana_endpoint_port" {
  description = "Instana backend endpoint port. Defaults to 443."
  type        = number
  default     = 443

  validation {
    condition     = var.instana_endpoint_port > 0 && var.instana_endpoint_port <= 65535
    error_message = "instana_endpoint_port must be between 1 and 65535."
  }
}

variable "instana_agent_mode" {
  description = "Instana agent mode. One of: APM, INFRASTRUCTURE, AWS, KUBERNETES, dynamic."
  type        = string
  default     = "dynamic"

  validation {
    condition     = contains(["APM", "INFRASTRUCTURE", "AWS", "KUBERNETES", "dynamic"], var.instana_agent_mode)
    error_message = "instana_agent_mode must be one of: APM, INFRASTRUCTURE, AWS, KUBERNETES, dynamic."
  }
}

variable "agent_max_memory" {
  description = <<-EOT
    Maximum heap memory for the Instana agent in MB.
    Increase for large environments. Must be between 512 and 8192 MB.
  EOT
  type        = number
  default     = 544

  validation {
    condition     = var.agent_max_memory >= 512 && var.agent_max_memory <= 8192
    error_message = "agent_max_memory must be between 512 and 8192 MB."
  }
}

variable "custom_config_yaml" {
  description = <<-EOT
    Raw YAML string to append to the Instana agent's configuration.yaml after installation.
    Leave null to skip custom configuration.

    Example:
      custom_config_yaml = file("$${path.module}/instana-config.yaml")
  EOT
  type        = string
  default     = null
}
