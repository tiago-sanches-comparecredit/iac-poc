#!/bin/bash

# =============================================================================
# Create New Vertical Script
# Automates vertical creation with Sanity datasets and Vercel infrastructure
#
# Prerequisites:
#   - Sanity project must be created manually first (get the project ID)
#   - VERCEL_API_TOKEN environment variable set
#   - Terraform installed
#   - Sanity CLI installed and logged in
#
# Usage:
#   ./create-vertical.sh --name "car-insurance" --sanity-project-id "abc123"
#
# Options:
#   --name              Vertical name (required, e.g., car-insurance)
#   --sanity-project-id Sanity project ID (required)
#   --display-name      Display name (optional, auto-generated from name)
#   --primary-color     Primary brand color (optional, default: #3b82f6)
#   --skip-sanity       Skip Sanity dataset/studio setup
#   --skip-vercel       Skip Vercel project creation
#   --dry-run           Show what would be created without executing
#
# Example:
#   ./create-vertical.sh --name "car-insurance" --sanity-project-id "xyz789" --primary-color "#10b981"
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
SANITY_DIR="$PROJECT_ROOT/sanity-cms"

# Default values
VERTICAL_NAME=""
SANITY_PROJECT_ID=""
DISPLAY_NAME=""
PRIMARY_COLOR="#3b82f6"
SECONDARY_COLOR="#1e40af"
SKIP_SANITY=false
SKIP_VERCEL=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            VERTICAL_NAME="$2"
            shift 2
            ;;
        --sanity-project-id)
            SANITY_PROJECT_ID="$2"
            shift 2
            ;;
        --display-name)
            DISPLAY_NAME="$2"
            shift 2
            ;;
        --primary-color)
            PRIMARY_COLOR="$2"
            shift 2
            ;;
        --secondary-color)
            SECONDARY_COLOR="$2"
            shift 2
            ;;
        --skip-sanity)
            SKIP_SANITY=true
            shift
            ;;
        --skip-vercel)
            SKIP_VERCEL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            head -30 "$0" | tail -25
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$VERTICAL_NAME" ]; then
    echo "Error: --name is required"
    echo "Usage: $0 --name <vertical-name> --sanity-project-id <id>"
    exit 1
fi

if [ -z "$SANITY_PROJECT_ID" ]; then
    echo "Error: --sanity-project-id is required"
    echo ""
    echo "To get a Sanity project ID:"
    echo "  1. Go to https://www.sanity.io/manage"
    echo "  2. Create a new project"
    echo "  3. Copy the project ID from the URL or dashboard"
    exit 1
fi

# Auto-generate display name if not provided
if [ -z "$DISPLAY_NAME" ]; then
    # Convert kebab-case to Title Case
    DISPLAY_NAME=$(echo "$VERTICAL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
fi

echo ""
echo "=========================================="
echo " Creating Vertical: $VERTICAL_NAME"
echo "=========================================="
echo ""
echo "Configuration:"
echo "  Name:             $VERTICAL_NAME"
echo "  Display Name:     $DISPLAY_NAME"
echo "  Sanity Project:   $SANITY_PROJECT_ID"
echo "  Primary Color:    $PRIMARY_COLOR"
echo "  Secondary Color:  $SECONDARY_COLOR"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if [ "$SKIP_VERCEL" = false ]; then
    if [ -z "$VERCEL_API_TOKEN" ]; then
        echo "Error: VERCEL_API_TOKEN environment variable is not set"
        echo "Get your token at: https://vercel.com/account/tokens"
        exit 1
    fi

    if ! command -v terraform &> /dev/null; then
        echo "Error: Terraform is not installed"
        echo "Install from: https://www.terraform.io/downloads"
        exit 1
    fi
    echo "  ✓ Vercel token found"
    echo "  ✓ Terraform installed"
fi

if [ "$SKIP_SANITY" = false ]; then
    if ! command -v npx &> /dev/null; then
        echo "Error: npx is not available (Node.js required)"
        exit 1
    fi
    echo "  ✓ Node.js/npx available"
fi

echo ""

# Show what will be created
echo "This will create:"
if [ "$SKIP_SANITY" = false ]; then
    echo "  - Sanity datasets: production, staging"
    echo "  - Sanity Studio deploy: ${VERTICAL_NAME}-cms.sanity.studio"
fi
if [ "$SKIP_VERCEL" = false ]; then
    echo "  - Vercel project: ${VERTICAL_NAME}-landing"
    echo "  - Environment variables for branding and Sanity"
fi
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Commands that would be executed:"
    echo ""
    if [ "$SKIP_SANITY" = false ]; then
        echo "# Sanity datasets"
        echo "cd $SANITY_DIR"
        echo "SANITY_STUDIO_PROJECT_ID=$SANITY_PROJECT_ID npx sanity dataset create production"
        echo "SANITY_STUDIO_PROJECT_ID=$SANITY_PROJECT_ID npx sanity dataset create staging"
        echo "SANITY_STUDIO_PROJECT_ID=$SANITY_PROJECT_ID npx sanity deploy --hostname ${VERTICAL_NAME}-cms"
        echo ""
    fi
    if [ "$SKIP_VERCEL" = false ]; then
        echo "# Terraform"
        echo "cd $TERRAFORM_DIR"
        echo "terraform init"
        echo "terraform apply \\"
        echo "  -state=\"states/${VERTICAL_NAME}.tfstate\" \\"
        echo "  -var=\"vertical_name=$VERTICAL_NAME\" \\"
        echo "  -var=\"vertical_display_name=$DISPLAY_NAME\" \\"
        echo "  -var=\"sanity_project_id=$SANITY_PROJECT_ID\" \\"
        echo "  -var=\"primary_color=$PRIMARY_COLOR\" \\"
        echo "  -var=\"secondary_color=$SECONDARY_COLOR\""
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

# -----------------------------------------------------------------------------
# Step 1: Sanity Setup
# -----------------------------------------------------------------------------
if [ "$SKIP_SANITY" = false ]; then
    echo ""
    echo "Step 1: Setting up Sanity..."
    echo "----------------------------"

    cd "$SANITY_DIR"

    # Create production dataset
    echo "Creating 'production' dataset..."
    SANITY_STUDIO_PROJECT_ID="$SANITY_PROJECT_ID" npx sanity dataset create production --visibility public 2>/dev/null || echo "  Dataset 'production' may already exist"

    # Create staging dataset
    echo "Creating 'staging' dataset..."
    SANITY_STUDIO_PROJECT_ID="$SANITY_PROJECT_ID" npx sanity dataset create staging --visibility public 2>/dev/null || echo "  Dataset 'staging' may already exist"

    # Deploy Sanity Studio
    echo "Deploying Sanity Studio..."
    SANITY_STUDIO_PROJECT_ID="$SANITY_PROJECT_ID" SANITY_STUDIO_DATASET="production" npx sanity deploy --hostname "${VERTICAL_NAME}-cms"

    echo "  ✓ Sanity Studio deployed to: https://${VERTICAL_NAME}-cms.sanity.studio"
fi

# -----------------------------------------------------------------------------
# Step 2: Vercel/Terraform Setup
# -----------------------------------------------------------------------------
if [ "$SKIP_VERCEL" = false ]; then
    echo ""
    echo "Step 2: Creating Vercel infrastructure..."
    echo "-----------------------------------------"

    cd "$TERRAFORM_DIR"

    # Create state directory for this vertical
    STATE_DIR="$TERRAFORM_DIR/states"
    mkdir -p "$STATE_DIR"

    # Initialize Terraform with backend for this vertical
    echo "Initializing Terraform..."
    terraform init -input=false

    # Apply Terraform with state file per vertical
    echo "Creating Vercel project and environment variables..."
    terraform apply \
        -state="$STATE_DIR/${VERTICAL_NAME}.tfstate" \
        -var="vertical_name=$VERTICAL_NAME" \
        -var="vertical_display_name=$DISPLAY_NAME" \
        -var="sanity_project_id=$SANITY_PROJECT_ID" \
        -var="primary_color=$PRIMARY_COLOR" \
        -var="secondary_color=$SECONDARY_COLOR" \
        -auto-approve

    echo "  ✓ Vercel project created"
fi

# -----------------------------------------------------------------------------
# Done!
# -----------------------------------------------------------------------------
echo ""
echo "=========================================="
echo " Vertical '$VERTICAL_NAME' created!"
echo "=========================================="
echo ""
echo "Resources created:"
if [ "$SKIP_SANITY" = false ]; then
    echo "  - Sanity Studio: https://${VERTICAL_NAME}-cms.sanity.studio"
    echo "  - Sanity Project ID: $SANITY_PROJECT_ID"
fi
if [ "$SKIP_VERCEL" = false ]; then
    echo "  - Vercel Project: ${VERTICAL_NAME}-landing"
    echo "  - Site URL: https://${VERTICAL_NAME}-landing.vercel.app"
fi
echo ""
echo "Next steps:"
echo "  1. Connect GitHub repo to Vercel project:"
echo "     https://vercel.com/${VERTICAL_NAME}-landing/settings/git"
echo "     - Repository: iac-poc"
echo "     - Root Directory: nextjs-template"
echo ""
echo "  2. Add content in Sanity Studio:"
echo "     https://${VERTICAL_NAME}-cms.sanity.studio"
echo "     - Create Settings (logo, site name)"
echo "     - Create Home (hero content)"
echo "     - Create Products"
echo ""
echo "  3. Trigger deploy by pushing to GitHub or manual redeploy"
echo ""
