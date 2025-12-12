/**
 * Main Terraform configuration for creating new verticals.
 *
 * This configuration creates:
 * 1. A Vercel project for the Next.js frontend
 * 2. Environment variables for branding and Sanity connection
 *
 * IMPORTANT: Content (hero, features, etc.) should be managed in Sanity CMS,
 * NOT in Terraform. Terraform only handles infrastructure and branding.
 *
 * Usage:
 *   terraform init
 *   terraform apply -var="vertical_name=pet-insurance" -var="sanity_project_id=abc123"
 */

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.0"
    }
  }
}

# Vercel API token - can be set via:
# 1. terraform.tfvars file (recommended)
# 2. Environment variable: VERCEL_API_TOKEN
# 3. Command line: -var="vercel_api_token=xxx"
variable "vercel_api_token" {
  description = "Vercel API token. Get it at https://vercel.com/account/tokens"
  type        = string
  sensitive   = true
  default     = ""
}

# Configure the Vercel provider
provider "vercel" {
  api_token = var.vercel_api_token != "" ? var.vercel_api_token : null
}

# -----------------------------------------------------------------------------
# Variables - Only infrastructure and branding, NO content
# -----------------------------------------------------------------------------

variable "vertical_name" {
  description = "Name of the vertical (e.g., pet-insurance, auto-loans). Used for project naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vertical_name))
    error_message = "Vertical name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vertical_display_name" {
  description = "Display name for the vertical (e.g., Pet Insurance). Auto-generated if empty."
  type        = string
  default     = ""
}

variable "primary_color" {
  description = "Primary brand color (hex code)"
  type        = string
  default     = "#3b82f6"
}

variable "secondary_color" {
  description = "Secondary brand color (hex code)"
  type        = string
  default     = "#1e40af"
}

variable "sanity_project_id" {
  description = "Sanity project ID for this vertical's CMS"
  type        = string
}

variable "sanity_dataset" {
  description = "Sanity dataset name"
  type        = string
  default     = "production"
}

variable "vercel_team_id" {
  description = "Vercel team ID (optional - for team deployments)"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  # Generate display name from vertical name if not provided
  display_name = var.vertical_display_name != "" ? var.vertical_display_name : title(replace(var.vertical_name, "-", " "))

  # Project name for Vercel
  project_name = "${var.vertical_name}-landing"
}

# -----------------------------------------------------------------------------
# Vercel Project
# -----------------------------------------------------------------------------

resource "vercel_project" "vertical" {
  name      = local.project_name
  framework = "nextjs"
  team_id   = var.vercel_team_id

  build_command    = "npm run build"
  output_directory = ".next"
  install_command  = "npm install"
}

# -----------------------------------------------------------------------------
# Environment Variables - Only branding + Sanity connection
# -----------------------------------------------------------------------------

resource "vercel_project_environment_variable" "site_name" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_SITE_NAME"
  value      = local.display_name
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "vertical" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_VERTICAL"
  value      = var.vertical_name
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "primary_color" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_PRIMARY_COLOR"
  value      = var.primary_color
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "secondary_color" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_SECONDARY_COLOR"
  value      = var.secondary_color
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "sanity_project_id" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_SANITY_PROJECT_ID"
  value      = var.sanity_project_id
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "sanity_dataset" {
  project_id = vercel_project.vertical.id
  team_id    = var.vercel_team_id
  key        = "NEXT_PUBLIC_SANITY_DATASET"
  value      = var.sanity_dataset
  target     = ["production", "preview", "development"]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "project_id" {
  description = "Vercel project ID"
  value       = vercel_project.vertical.id
}

output "project_name" {
  description = "Vercel project name"
  value       = vercel_project.vertical.name
}

output "project_url" {
  description = "Vercel project URL (after first deployment)"
  value       = "https://${local.project_name}.vercel.app"
}

output "next_steps" {
  description = "Instructions for completing setup"
  value       = <<-EOT

    Project created! Next steps:

    1. Connect GitHub repo to Vercel project:
       - Go to https://vercel.com/${local.project_name}/settings/git
       - Or run: vercel link

    2. Add content in Sanity Studio:
       - Create Hero Section document
       - Create Feature documents

    3. Deploy by pushing to GitHub

  EOT
}
