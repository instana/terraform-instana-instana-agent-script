terraform {
  required_version = ">= 1.3.0"
  # No provider required — this module uses only built-in Terraform functions
  # (templatefile, base64encode, coalesce).
}
