#!/bin/bash

# =============================================================================
# Create New Vertical Script
# One-command setup for a new vertical with Vercel and optional Sanity
#
# Usage: ./create-vertical.sh <vertical-name> [options]
#
# Options:
#   --with-sanity    Also create a Sanity project
#   --dry-run        Show what would be created without actually creating
#
# Example:
#   ./create-vertical.sh pet-insurance --with-sanity
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

# Parse arguments
VERTICAL_NAME=""
WITH_SANITY=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --with-sanity)
            WITH_SANITY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [ -z "$VERTICAL_NAME" ]; then
                VERTICAL_NAME=$1
            fi
            shift
            ;;
    esac
done

if [ -z "$VERTICAL_NAME" ]; then
    echo "Error: Vertical name is required"
    echo ""
    echo "Usage: $0 <vertical-name> [options]"
    echo ""
    echo "Options:"
    echo "  --with-sanity    Also create a Sanity project"
    echo "  --dry-run        Show what would be created"
    echo ""
    echo "Example:"
    echo "  $0 pet-insurance --with-sanity"
    exit 1
fi

echo "==================================="
echo "Creating New Vertical: $VERTICAL_NAME"
echo "==================================="
echo ""

# Check for required environment variables
if [ -z "$VERCEL_API_TOKEN" ]; then
    echo "Warning: VERCEL_API_TOKEN not set"
    echo "Get your token from: https://vercel.com/account/tokens"
    echo ""
fi

# Check for Terraform
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed"
    echo "Install from: https://www.terraform.io/downloads"
    exit 1
fi

# Check if tfvars file exists for this vertical
TFVARS_FILE="$TERRAFORM_DIR/verticals/${VERTICAL_NAME}.tfvars"
if [ -f "$TFVARS_FILE" ]; then
    echo "Found configuration: $TFVARS_FILE"
else
    echo "No pre-defined configuration found for '$VERTICAL_NAME'"
    echo "Using default values (you can customize later)"
    TFVARS_FILE=""
fi

echo ""

# Show what will be created
echo "This will create:"
echo "  - Vercel project: ${VERTICAL_NAME}-landing"
echo "  - Environment variables for branding"
if [ "$WITH_SANITY" = true ]; then
    echo "  - Sanity CMS project: ${VERTICAL_NAME}-cms"
fi
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute:"
    echo "  cd $TERRAFORM_DIR"
    echo "  terraform init"
    if [ -n "$TFVARS_FILE" ]; then
        echo "  terraform plan -var-file=\"$TFVARS_FILE\""
    else
        echo "  terraform plan -var=\"vertical_name=$VERTICAL_NAME\""
    fi
    exit 0
fi

# Confirm
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
cd "$TERRAFORM_DIR"
terraform init

# Run Terraform
echo ""
echo "Creating infrastructure..."
if [ -n "$TFVARS_FILE" ]; then
    terraform apply -var-file="$TFVARS_FILE" -auto-approve
else
    terraform apply -var="vertical_name=$VERTICAL_NAME" -auto-approve
fi

# Create Sanity project if requested
if [ "$WITH_SANITY" = true ]; then
    echo ""
    echo "Creating Sanity project..."
    cd "$SCRIPT_DIR"
    ./setup-sanity.sh "$VERTICAL_NAME"
fi

echo ""
echo "==================================="
echo "Vertical '$VERTICAL_NAME' created!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Push code to trigger deployment"
echo "2. Visit https://${VERTICAL_NAME}-landing.vercel.app"
if [ "$WITH_SANITY" = true ]; then
    echo "3. Deploy Sanity Studio for CMS access"
fi
