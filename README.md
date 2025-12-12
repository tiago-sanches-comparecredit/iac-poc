# IaC POC - Multi-Vertical Landing Page Infrastructure

This proof-of-concept demonstrates how to use Infrastructure as Code (Terraform) to automatically provision new product verticals (landing pages) with their own CMS.

## Architecture Overview

```
                    ┌─────────────────────────────────────────┐
                    │          terraform apply                 │
                    │     -var="vertical_name=pet-insurance"   │
                    └─────────────────┬───────────────────────┘
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │              Terraform                   │
                    │         (Infrastructure as Code)         │
                    └─────────────────┬───────────────────────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              │                                               │
              ▼                                               ▼
    ┌─────────────────┐                           ┌─────────────────┐
    │     Vercel      │                           │     Sanity      │
    │   (Frontend)    │◄─────── fetches ─────────►│     (CMS)       │
    │                 │         content           │                 │
    └─────────────────┘                           └─────────────────┘
    │                                             │
    │  pet-insurance-landing.vercel.app           │  Sanity Studio
    │  auto-loans-landing.vercel.app              │  (content editing)
    │  debt-relief-landing.vercel.app             │
    └─────────────────────────────────────────────┘
```

## Project Structure

```
iac-poc/
├── nextjs-template/          # Next.js landing page template
│   ├── src/
│   │   ├── app/              # App Router pages
│   │   ├── components/       # React components (Header, Hero, ProductList, Footer)
│   │   ├── config/           # Site configuration from env vars
│   │   └── lib/              # Sanity client and queries
│   └── .env.local            # Environment variables (not committed)
│
├── sanity-cms/               # Sanity Studio template
│   ├── schemas/              # Content schemas (settings, home, product)
│   ├── sanity.config.ts      # Studio configuration
│   └── .env.example          # CMS environment variables
│
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── terraform.tfvars.example
│   └── states/               # State files per vertical (not committed)
│
└── scripts/                  # Helper scripts
    └── create-vertical.sh    # Automated vertical creation
```

## Prerequisites

1. **Node.js** (v18 or higher)
2. **Terraform** (v1.0 or higher)
3. **Vercel Account** with API token
4. **Sanity Account** (optional, for CMS features)

## Quick Start

### 1. Install Terraform

**Windows (Chocolatey):**
```bash
choco install terraform
```

**macOS (Homebrew):**
```bash
brew install terraform
```

**Manual:** Download from https://www.terraform.io/downloads

### 2. Set Environment Variables

```bash
# Required for Vercel deployments
export VERCEL_API_TOKEN="your-vercel-token"

# Optional for Sanity CMS
export SANITY_AUTH_TOKEN="your-sanity-token"
```

Get your tokens:
- Vercel: https://vercel.com/account/tokens
- Sanity: https://www.sanity.io/manage/personal/api-tokens

### 3. Create a New Vertical

**Step 1:** Create a Sanity project manually at https://www.sanity.io/manage and copy the project ID.

**Step 2:** Run the create-vertical script:

```bash
# Preview what will be created (dry run)
./scripts/create-vertical.sh --name "car-insurance" --sanity-project-id "your-project-id" --dry-run

# Create the vertical
./scripts/create-vertical.sh --name "car-insurance" --sanity-project-id "your-project-id"

# With custom branding
./scripts/create-vertical.sh \
  --name "car-insurance" \
  --sanity-project-id "your-project-id" \
  --display-name "Car Insurance" \
  --primary-color "#10b981"
```

**What the script does:**
1. Creates Sanity datasets (`production` and `staging`)
2. Deploys Sanity Studio to `{vertical}-cms.sanity.studio`
3. Creates Vercel project via Terraform
4. Configures all environment variables

**Script options:**
| Option | Description |
|--------|-------------|
| `--name` | Vertical name (required, e.g., car-insurance) |
| `--sanity-project-id` | Sanity project ID (required) |
| `--display-name` | Display name (optional, auto-generated) |
| `--primary-color` | Brand color (optional, default: #3b82f6) |
| `--skip-sanity` | Skip Sanity setup |
| `--skip-vercel` | Skip Vercel setup |
| `--dry-run` | Preview without executing |

**Step 3:** Connect the GitHub repo to the new Vercel project:
1. Go to https://vercel.com/{vertical-name}-landing/settings/git
2. Connect the `iac-poc` repository
3. Set Root Directory to `nextjs-template`

## Customizing a Vertical

### Environment Variables

Each vertical can be customized via environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXT_PUBLIC_SITE_NAME` | Site display name | "Pet Insurance Hub" |
| `NEXT_PUBLIC_SITE_DESCRIPTION` | Meta description | "Protect your pets..." |
| `NEXT_PUBLIC_VERTICAL` | Vertical identifier | "pet-insurance" |
| `NEXT_PUBLIC_PRIMARY_COLOR` | Brand color (hex) | "#10b981" |
| `NEXT_PUBLIC_HERO_TITLE` | Hero headline | "Protect Your Pets" |
| `NEXT_PUBLIC_HERO_SUBTITLE` | Hero subtext | "Comprehensive coverage..." |
| `NEXT_PUBLIC_CTA_TEXT` | Button text | "Get a Quote" |
| `NEXT_PUBLIC_CTA_LINK` | Button URL | "/quote" |
| `NEXT_PUBLIC_SANITY_PROJECT_ID` | Sanity project ID | "abc123" |

### Terraform Variables

Create a `.tfvars` file for your vertical:

```hcl
# my-vertical.tfvars
vertical_name         = "my-vertical"
vertical_display_name = "My Vertical"
primary_color         = "#3b82f6"
hero_title           = "Welcome to My Vertical"
cta_text             = "Get Started"
```

Apply with:
```bash
terraform apply -var-file="my-vertical.tfvars"
```

## Adding CMS Content

### 1. Deploy Sanity Studio

```bash
cd sanity-cms
npm install
SANITY_STUDIO_PROJECT_ID=your-project-id npm run deploy
```

### 2. Add Content

1. Open your Sanity Studio (e.g., `https://your-studio.sanity.studio`)
2. Create a **Hero Section** document
3. Create **Feature** documents
4. Content will be fetched by the Next.js frontend

### 3. Content Schemas

**Settings (singleton):**
- siteName (string)
- logo (image, optional)
- logoAlt (string)

**Home (singleton):**
- title (string) - Hero title
- subtitle (text) - Hero subtitle
- ctaText (string)
- ctaLink (string)

**Product:**
- name (string)
- slug (slug)
- image (image, optional)
- details (array of strings) - Bullet points
- ctaText (string)
- ctaLink (string)
- order (number)

## Development

### Running Locally

```bash
# Next.js frontend
cd nextjs-template
cp .env.example .env.local
npm install
npm run dev

# Sanity Studio
cd sanity-cms
cp .env.example .env
npm install
npm run dev
```

### Building

```bash
cd nextjs-template
npm run build
```

## Limitations (POC Scope)

This POC demonstrates the concept but has some limitations:

1. **Git Integration:** Vercel project created but requires manual git connection or API setup for automatic deployments
2. **Sanity Provider:** No official Terraform provider - uses scripts/API calls
3. **State Management:** Local Terraform state (production would use remote backend)
4. **Secrets:** Tokens in environment variables (production would use Vault/secrets manager)

## Extending This POC

For production use, consider:

1. **Remote State:** Use Terraform Cloud or S3 backend
2. **CI/CD Pipeline:** GitHub Actions or similar for automated deployments
3. **Secret Management:** HashiCorp Vault, AWS Secrets Manager, etc.
4. **Monitoring:** Add observability (Datadog, New Relic, etc.)
5. **Multi-environment:** Add staging/production separation
6. **Host Sanity Studio on Vercel:** See below

### Hosting Sanity Studio on Vercel

Currently, the Sanity Studio is deployed to Sanity's hosted service (`*.sanity.studio`). However, it can also be hosted on Vercel for a unified infrastructure.

**Benefits of hosting on Vercel:**
- All infrastructure managed in one place
- Easier custom domain configuration
- Full Terraform automation for both frontend and CMS

**How it works:**

The Sanity Studio is a React application that builds to static files:

```bash
npx sanity build  # Generates a "dist" folder with static HTML/JS/CSS
```

**Terraform configuration to add CMS to Vercel:**

```hcl
# In addition to the frontend project, create a CMS project
resource "vercel_project" "cms" {
  name             = "${var.vertical_name}-cms"
  framework        = null  # Static site
  build_command    = "npx sanity build"
  output_directory = "dist"
  team_id          = var.vercel_team_id
}

# Environment variables for the CMS
resource "vercel_project_environment_variable" "cms_project_id" {
  project_id = vercel_project.cms.id
  key        = "SANITY_STUDIO_PROJECT_ID"
  value      = var.sanity_project_id
  target     = ["production", "preview", "development"]
}

resource "vercel_project_environment_variable" "cms_dataset" {
  project_id = vercel_project.cms.id
  key        = "SANITY_STUDIO_DATASET"
  value      = var.sanity_dataset
  target     = ["production", "preview", "development"]
}
```

This would result in:
- Frontend: `https://pet-insurance-landing.vercel.app`
- CMS: `https://pet-insurance-cms.vercel.app`

Both fully managed via Terraform.

## Resources

- [Terraform Vercel Provider](https://registry.terraform.io/providers/vercel/vercel/latest/docs)
- [Sanity Management API](https://www.sanity.io/docs/management-api)
- [Next.js Documentation](https://nextjs.org/docs)
- [Vercel CLI](https://vercel.com/docs/cli)
