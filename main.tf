# ==============================================================================
# terraform-instana-agent-script
# ==============================================================================
#
# A cloud-agnostic Terraform module that renders an Instana agent bootstrap
# script for Linux and Windows VMs. Accepts agent credentials and configuration
# as inputs and produces four output variants:
#
#   linux_agent_bootstrap           — plain text  (AWS user_data, GCP startup-script)
#   linux_agent_bootstrap_base64    — base64      (Azure Linux custom_data)
#   windows_agent_bootstrap         — plain text  (AWS user_data, GCP windows-startup-script-ps1)
#   windows_agent_bootstrap_base64  — base64      (Azure Windows custom_data)
#
# This module creates NO cloud resources and requires NO provider configuration.
# It works with any Terraform root module targeting AWS, Azure, or GCP.
#
# Supported Linux distributions:
#   - Debian / Ubuntu              (apt-get)
#   - Fedora / RHEL 8+ / Rocky / AlmaLinux  (dnf)
#   - Amazon Linux 2 / 2023 / RHEL 7 / CentOS 7  (yum)
#   - SLES 12/15 / openSUSE Leap / Tumbleweed  (zypper)
#   - Alpine Linux 3.x             (apk)
#   - Arch Linux / Manjaro         (pacman)
#
# Supported Windows versions:
#   - Windows Server 2019 / 2022
#   - Windows 10 / 11 (64-bit)
#
# See README.md for full usage documentation and examples.
# ==============================================================================
