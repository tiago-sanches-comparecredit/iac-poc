/**
 * Sanity project provisioning using local-exec.
 *
 * NOTE: Sanity does not have an official Terraform provider.
 * This configuration uses the Sanity CLI via local-exec provisioner.
 *
 * Prerequisites:
 * - Sanity CLI installed: npm install -g @sanity/cli
 * - Logged in to Sanity: sanity login
 * - SANITY_AUTH_TOKEN environment variable set
 */

variable "create_sanity_project" {
  description = "Whether to create a new Sanity project for this vertical"
  type        = bool
  default     = false
}

variable "sanity_organization" {
  description = "Sanity organization ID (required if creating new project)"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Sanity Project Creation (via API)
# -----------------------------------------------------------------------------

# This null_resource creates a Sanity project using the Sanity Management API
resource "null_resource" "sanity_project" {
  count = var.create_sanity_project ? 1 : 0

  triggers = {
    vertical_name = var.vertical_name
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      # Create Sanity project via Management API
      curl -s -X POST \
        -H "Authorization: Bearer $SANITY_AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "displayName": "${local.display_name} CMS",
          "organizationId": "${var.sanity_organization}",
          "metadata": {
            "vertical": "${var.vertical_name}"
          }
        }' \
        "https://api.sanity.io/v2021-06-07/projects" \
        > sanity_project_${var.vertical_name}.json

      # Extract project ID
      PROJECT_ID=$(cat sanity_project_${var.vertical_name}.json | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
      echo "Created Sanity project: $PROJECT_ID"

      # Create production dataset
      curl -s -X PUT \
        -H "Authorization: Bearer $SANITY_AUTH_TOKEN" \
        "https://api.sanity.io/v2021-06-07/projects/$PROJECT_ID/datasets/production"

      echo "Sanity project setup complete!"
    EOT
  }
}

# -----------------------------------------------------------------------------
# Alternative: Script-based Sanity setup
# -----------------------------------------------------------------------------

# For more complex setups, you can use an external script
resource "null_resource" "sanity_setup_script" {
  count = var.create_sanity_project && var.sanity_organization != "" ? 1 : 0

  triggers = {
    vertical_name = var.vertical_name
    always_run    = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../scripts"
    command     = "bash setup-sanity.sh ${var.vertical_name} ${local.display_name}"

    environment = {
      SANITY_ORG_ID = var.sanity_organization
    }
  }

  depends_on = [null_resource.sanity_project]
}
