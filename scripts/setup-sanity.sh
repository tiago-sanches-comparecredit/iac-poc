#!/bin/bash

# =============================================================================
# Sanity Project Setup Script
# Creates a new Sanity project for a vertical
#
# Usage: ./setup-sanity.sh <vertical-name> <display-name>
# Example: ./setup-sanity.sh pet-insurance "Pet Insurance Hub"
#
# Required environment variables:
# - SANITY_AUTH_TOKEN: Your Sanity authentication token
# - SANITY_ORG_ID: (optional) Organization ID for the project
# =============================================================================

set -e

VERTICAL_NAME=$1
DISPLAY_NAME=${2:-$VERTICAL_NAME}

if [ -z "$VERTICAL_NAME" ]; then
    echo "Error: Vertical name is required"
    echo "Usage: $0 <vertical-name> [display-name]"
    exit 1
fi

if [ -z "$SANITY_AUTH_TOKEN" ]; then
    echo "Error: SANITY_AUTH_TOKEN environment variable is not set"
    echo "Get your token from: https://www.sanity.io/manage/personal/api-tokens"
    exit 1
fi

echo "==================================="
echo "Setting up Sanity project"
echo "Vertical: $VERTICAL_NAME"
echo "Display Name: $DISPLAY_NAME"
echo "==================================="

# Create project via API
echo "Creating Sanity project..."

PROJECT_DATA=$(cat <<EOF
{
  "displayName": "${DISPLAY_NAME} CMS"
}
EOF
)

# Add organization if provided
if [ -n "$SANITY_ORG_ID" ]; then
    PROJECT_DATA=$(cat <<EOF
{
  "displayName": "${DISPLAY_NAME} CMS",
  "organizationId": "$SANITY_ORG_ID"
}
EOF
)
fi

RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $SANITY_AUTH_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$PROJECT_DATA" \
    "https://api.sanity.io/v2021-06-07/projects")

# Extract project ID
PROJECT_ID=$(echo $RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Failed to create Sanity project"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "Created project: $PROJECT_ID"

# Create production dataset
echo "Creating production dataset..."
curl -s -X PUT \
    -H "Authorization: Bearer $SANITY_AUTH_TOKEN" \
    "https://api.sanity.io/v2021-06-07/projects/$PROJECT_ID/datasets/production"

echo ""
echo "==================================="
echo "Sanity project created successfully!"
echo "==================================="
echo ""
echo "Project ID: $PROJECT_ID"
echo "Dataset: production"
echo ""
echo "Next steps:"
echo "1. Add this to your Terraform variables:"
echo "   sanity_project_id = \"$PROJECT_ID\""
echo ""
echo "2. Or set environment variable:"
echo "   export NEXT_PUBLIC_SANITY_PROJECT_ID=$PROJECT_ID"
echo ""
echo "3. Deploy Sanity Studio:"
echo "   cd sanity-cms"
echo "   SANITY_STUDIO_PROJECT_ID=$PROJECT_ID npm run deploy"
echo ""

# Save project info to file
echo "$PROJECT_ID" > "sanity-project-${VERTICAL_NAME}.txt"
echo "Project ID saved to: sanity-project-${VERTICAL_NAME}.txt"
