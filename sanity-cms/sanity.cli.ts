import { defineCliConfig } from "sanity/cli";

/**
 * Sanity CLI configuration.
 * Used for deploying the studio and managing datasets.
 */
export default defineCliConfig({
  api: {
    projectId: process.env.SANITY_STUDIO_PROJECT_ID || "your-project-id",
    dataset: process.env.SANITY_STUDIO_DATASET || "production",
  },
  studioHost: process.env.SANITY_STUDIO_HOST,
});
