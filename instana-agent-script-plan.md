# Plan: terraform-instana-agent-script Module

## Top-Level Overview

Create a new, cloud-agnostic Terraform module (`terraform-instana-agent-script`) that accepts Instana
agent credentials and configuration as inputs and outputs a rendered bootstrap script for Linux VMs.

### Confirmed Design Decisions
- **Distro support**: Amazon Linux + Debian/Ubuntu only (yum/apt detection).
- **Agent mode validation**: `["APM", "INFRASTRUCTURE", "AWS", "KUBERNETES", "dynamic"]` — same as the GCP module.
- **Output sensitivity**: Both outputs are `sensitive = true`.

The module produces **three output variants** from a single shared script template:
- `linux_agent_bootstrap` — plain text script (for AWS `user_data` and GCP `startup-script`)
- `linux_agent_bootstrap_base64` — base64-encoded version (for Azure `custom_data`)

The module creates **no cloud resources** — it is a pure data/output module using `templatefile()` and
Terraform built-in functions only. No provider block is required (beyond the implicit `terraform`
`required_version`).

### Key Design Decisions
- No cloud-specific providers required; the `hashicorp/local` provider is not needed either since the
  file is embedded via `templatefile()` at `path.module`.
- `instana_download_key` is optional; defaults to `instana_agent_key` when not provided.
- `custom_config_yaml` is an optional string input; if provided it is base64-encoded and baked into
  the rendered script directly (no file path reading — the caller provides the string content).
- GCP service-account credential injection is **out of scope**.
- Azure only needs the base64 variant; AWS and GCP use plain text.
- The script is modelled on `terraform-gcp-instana-agent/startup-script.sh` (robust logging, cleanup,
  prerequisite install) but strips the GCP-specific metadata-server lookup and GCP credential setup
  sections. Configuration is injected directly into the script via `templatefile()` substitution.

---

## Sub-Tasks

---

### Sub-Task 1 — Bootstrap script template

**Intent**  
Create the shared shell script template (`templates/linux_agent_bootstrap.sh.tftpl`) that works on
both `apt`-based (Debian/Ubuntu) and `yum`/`dnf`-based (Amazon Linux / RHEL) distributions. Values
are injected directly at render time via `templatefile()` — no runtime metadata-server calls needed.

**Expected Outcomes**
- A single `.sh.tftpl` file exists under `terraform-instana-agent-script/templates/`.
- The script installs prerequisites (`curl`, `apt-transport-https` or equivalent), downloads
  `https://setup.instana.io/agent`, and invokes it with `-a`, `-d`, `-t`, `-e`, `-s`, `-y` flags.
- If `custom_config_yaml_base64` is non-empty (controlled by a template conditional `%{ if ... }`),
  the script decodes it and appends it to `/opt/instana/agent/etc/instana/configuration.yaml`.
- Logging follows the pattern from the GCP startup script (timestamped log to `/var/log/instana-agent-install.log`).
- Sensitive variables (`INSTANA_AGENT_KEY`, `INSTANA_DOWNLOAD_KEY`) are `unset` at the end of the
  script.

**Todo List**
1. Create `terraform-instana-agent-script/templates/` directory (implicit via file creation).
2. Write `templates/linux_agent_bootstrap.sh.tftpl` with template variables:
   `${instana_agent_key}`, `${instana_download_key}`, `${instana_endpoint_host}`,
   `${instana_endpoint_port}`, `${instana_agent_mode}`, `${agent_max_memory}`,
   `${custom_config_yaml_base64}`.
3. Include a `%{ if custom_config_yaml_base64 != "" }` block that decodes and appends custom config.
4. Mirror the cleanup + prerequisite + dual-distro install pattern (yum/apt detection, like the AWS
   template) combined with the robust logging and `set -e`/`set -o pipefail` from the GCP script.

**Relevant Context**
- [`terraform-gcp-instana-agent/startup-script.sh`](../terraform-gcp-instana-agent/startup-script.sh) — logging pattern, cleanup, custom config append logic
- [`terraform-aws-instana-ec2-agent/templates/user_data.sh.tftpl`](../terraform-aws-instana-ec2-agent/templates/user_data.sh.tftpl) — dual-distro (yum/apt) detection, `templatefile` substitution style

**Status** — `[ ] pending`

---

### Sub-Task 2 — `variables.tf`

**Intent**  
Define all input variables for the module. Only Instana-related variables are included; no
cloud-provider-specific inputs.

**Expected Outcomes**
- `terraform-instana-agent-script/variables.tf` exists with variables described below.
- All sensitive variables are marked `sensitive = true`.
- Validations mirror patterns from the existing modules (non-empty strings, port range, mode enum).

**Variable list**

| Name | Type | Required | Default | Notes |
|------|------|----------|---------|-------|
| `instana_agent_key` | `string` | yes | — | sensitive |
| `instana_download_key` | `string` | no | `null` | sensitive; defaults to `instana_agent_key` in locals |
| `instana_endpoint_host` | `string` | yes | — | e.g. `ingress-pink-saas.instana.rocks` |
| `instana_endpoint_port` | `number` | no | `443` | validated 1–65535 |
| `instana_agent_mode` | `string` | no | `"dynamic"` | validated enum: APM, INFRASTRUCTURE, AWS, KUBERNETES, dynamic |
| `agent_max_memory` | `number` | no | `544` | validated 512–8192 MB |
| `custom_config_yaml` | `string` | no | `null` | raw YAML string; base64-encoded in locals |

**Todo List**
1. Create `terraform-instana-agent-script/variables.tf` with all variables above.
2. Add `validation` blocks matching the existing module conventions.

**Relevant Context**
- [`terraform-gcp-instana-agent/variables.tf`](../terraform-gcp-instana-agent/variables.tf) — variable style, validation conventions
- [`terraform-aws-instana-ec2-agent/variable.tf`](../terraform-aws-instana-ec2-agent/variable.tf) — sensitive marking, description style

**Status** — `[ ] pending`

---

### Sub-Task 3 — `locals.tf`

**Intent**  
Derive computed values used by the template rendering: effective download key, base64-encoded custom
config, the rendered script string, and the base64 version of it.

**Expected Outcomes**
- `terraform-instana-agent-script/locals.tf` exists.
- `effective_download_key` = `coalesce(var.instana_download_key, var.instana_agent_key)`.
- `custom_config_yaml_base64` = `var.custom_config_yaml != null ? base64encode(var.custom_config_yaml) : ""`.
- `linux_agent_bootstrap` = `templatefile("${path.module}/templates/linux_agent_bootstrap.sh.tftpl", { ... })` — all template vars resolved here.
- `linux_agent_bootstrap_base64` = `base64encode(local.linux_agent_bootstrap)`.

**Todo List**
1. Create `terraform-instana-agent-script/locals.tf`.
2. Define `effective_download_key` using `coalesce()`.
3. Define `custom_config_yaml_base64`.
4. Define `linux_agent_bootstrap` via `templatefile()` passing all required template variables.
5. Define `linux_agent_bootstrap_base64` via `base64encode(local.linux_agent_bootstrap)`.

**Relevant Context**
- [`terraform-gcp-instana-agent/locals.tf`](../terraform-gcp-instana-agent/locals.tf) — `templatefile` pattern, base64 encoding pattern

**Status** — `[ ] pending`

---

### Sub-Task 4 — `outputs.tf`

**Intent**  
Expose the rendered script in both plain-text and base64-encoded forms. Outputs are marked `sensitive`
because they contain the baked-in agent key.

**Expected Outcomes**
- `terraform-instana-agent-script/outputs.tf` exists with the two outputs below.
- Both outputs are `sensitive = true`.

**Output list**

| Name | Value | Use |
|------|-------|-----|
| `linux_agent_bootstrap` | `local.linux_agent_bootstrap` | AWS `user_data`, GCP `startup-script` metadata value |
| `linux_agent_bootstrap_base64` | `local.linux_agent_bootstrap_base64` | Azure `custom_data` |

**Todo List**
1. Create `terraform-instana-agent-script/outputs.tf` with both outputs.
2. Mark both `sensitive = true` with clear `description` fields.

**Status** — `[ ] pending`

---

### Sub-Task 5 — `versions.tf` and `main.tf`

**Intent**  
Declare Terraform version constraints and provide a module-level documentation header. No provider
block is needed — this module uses only built-in Terraform functions (`templatefile`, `base64encode`,
`coalesce`).

**Expected Outcomes**
- `versions.tf` requires `terraform >= 1.3.0` (matching the lower of the two existing modules).
- `main.tf` contains only a descriptive comment block (no resources).

**Todo List**
1. Create `terraform-instana-agent-script/versions.tf` with `required_version = ">= 1.3.0"` and no
   `required_providers` block.
2. Create `terraform-instana-agent-script/main.tf` with a module overview comment.

**Status** — `[ ] pending`

---

### Sub-Task 6 — `examples/` and `README.md`

**Intent**  
Provide a working usage example and update the README so users can quickly onboard. The example shows
the module wired up for all three clouds using the three different output attributes.

**Expected Outcomes**
- `examples/basic/main.tf` shows how to call the module and consume its outputs for AWS, GCP, and
  Azure (separate resource stubs with comments).
- `examples/basic/variables.tf` and `examples/basic/terraform.tfvars.example` exist.
- `README.md` is updated with: purpose, input variable table, output table, and copy-paste usage
  snippets for AWS, Azure, and GCP.

**Todo List**
1. Create `terraform-instana-agent-script/examples/basic/main.tf`.
2. Create `terraform-instana-agent-script/examples/basic/variables.tf`.
3. Create `terraform-instana-agent-script/examples/basic/terraform.tfvars.example`.
4. Overwrite `terraform-instana-agent-script/README.md` with full module documentation.

**Relevant Context**
- [`terraform-aws-instana-ec2-agent/examples/basic/main.tf`](../terraform-aws-instana-ec2-agent/examples/basic/main.tf) — example style
- [`terraform-gcp-instana-agent/examples/basic/main.tf`](../terraform-gcp-instana-agent/examples/basic/main.tf) — example style

**Status** — `[ ] pending`
