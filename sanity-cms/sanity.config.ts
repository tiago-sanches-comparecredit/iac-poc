import { defineConfig } from "sanity";
import { structureTool } from "sanity/structure";
import { schemaTypes } from "./schemas";

/**
 * Sanity Studio configuration.
 * Project ID and dataset are loaded from environment variables
 * to support multiple verticals with the same codebase.
 */
export default defineConfig({
  name: "default",
  title: process.env.SANITY_STUDIO_PROJECT_TITLE || "Vertical CMS",

  projectId: process.env.SANITY_STUDIO_PROJECT_ID || "your-project-id",
  dataset: process.env.SANITY_STUDIO_DATASET || "production",

  plugins: [structureTool()],

  schema: {
    types: schemaTypes,
  },
});
