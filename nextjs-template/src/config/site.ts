/**
 * Site configuration loaded from environment variables.
 *
 * This file contains ONLY branding/infrastructure settings.
 * Content (hero, features, etc.) comes from Sanity CMS.
 */

export const siteConfig = {
  // Basic site information (set by Terraform)
  name: process.env.NEXT_PUBLIC_SITE_NAME || "Default Site",
  vertical: process.env.NEXT_PUBLIC_VERTICAL || "default",

  // Branding (set by Terraform)
  primaryColor: process.env.NEXT_PUBLIC_PRIMARY_COLOR || "#3b82f6",
  secondaryColor: process.env.NEXT_PUBLIC_SECONDARY_COLOR || "#1e40af",

  // Sanity CMS configuration (set by Terraform)
  sanity: {
    projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID || "",
    dataset: process.env.NEXT_PUBLIC_SANITY_DATASET || "production",
    apiVersion: process.env.NEXT_PUBLIC_SANITY_API_VERSION || "2024-01-01",
  },
};

export type SiteConfig = typeof siteConfig;
