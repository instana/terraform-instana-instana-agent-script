# ==============================================================================
# terraform-instana-agent-script
# ==============================================================================
#
# A cloud-agnostic Terraform module that renders an Instana agent bootstrap
# script for Linux VMs. Accepts agent credentials and configuration as inputs
# and produces two output variants:
#
#   linux_agent_bootstrap        — plain text  (AWS user_data, GCP startup-script)
#   linux_agent_bootstrap_base64 — base64      (Azure custom_data)
#
# This module creates NO cloud resources and requires NO provider configuration.
# It works with any Terraform root module targeting AWS, Azure, or GCP.
#
# Supported Linux distributions:
#   - Debian / Ubuntu  (apt-get)
#   - Amazon Linux 2 / 2023  (yum)
#
# See README.md for full usage documentation and examples.
# ==============================================================================
