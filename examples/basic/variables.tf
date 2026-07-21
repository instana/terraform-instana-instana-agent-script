variable "instana_agent_key" {
  description = "Instana agent key for authentication."
  type        = string
  sensitive   = true
}

variable "instana_endpoint_host" {
  description = "Instana backend endpoint host (e.g. ingress-pink-saas.instana.rocks)."
  type        = string
}

variable "instana_download_key" {
  description = "Instana download key. Defaults to instana_agent_key when not provided."
  type        = string
  sensitive   = true
  default     = null
}
