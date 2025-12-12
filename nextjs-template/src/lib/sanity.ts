import { createClient, type SanityClient } from "@sanity/client";
import imageUrlBuilder, { type SanityImageSource } from "@sanity/image-url";
import { siteConfig } from "@/config/site";

/**
 * Helper to check if Sanity is configured.
 * Returns false if project ID is missing.
 */
export function isSanityConfigured(): boolean {
  return Boolean(siteConfig.sanity.projectId);
}

/**
 * Sanity client instance.
 * Only created when project ID is configured.
 */
let _client: SanityClient | null = null;

/**
 * Get the Sanity client.
 * Returns null if Sanity is not configured (no project ID).
 */
export function getClient(): SanityClient | null {
  if (!isSanityConfigured()) {
    return null;
  }

  if (!_client) {
    _client = createClient({
      projectId: siteConfig.sanity.projectId,
      dataset: siteConfig.sanity.dataset,
      apiVersion: siteConfig.sanity.apiVersion,
      useCdn: true, // Enable CDN for faster reads in production
    });
  }

  return _client;
}

// Legacy export for backwards compatibility
export const client = isSanityConfigured()
  ? createClient({
      projectId: siteConfig.sanity.projectId,
      dataset: siteConfig.sanity.dataset,
      apiVersion: siteConfig.sanity.apiVersion,
      useCdn: true,
    })
  : null;

/**
 * Image URL builder for Sanity images.
 * Use: urlFor(image).width(800).url()
 * Returns null if Sanity is not configured.
 */
export function urlFor(source: SanityImageSource) {
  const sanityClient = getClient();
  if (!sanityClient) {
    return null;
  }
  const builder = imageUrlBuilder(sanityClient);
  return builder.image(source);
}
