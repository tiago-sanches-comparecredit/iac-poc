import { getClient, isSanityConfigured } from "./sanity";
import { landingPageQuery } from "./queries";

/**
 * Types for Sanity content
 */
export interface Settings {
  siteName: string;
  logo?: {
    asset: {
      url: string;
    };
  };
  logoAlt?: string;
}

export interface HomeContent {
  title: string;
  subtitle: string;
  ctaText: string;
  ctaLink: string;
}

export interface Product {
  _id: string;
  name: string;
  slug: { current: string };
  image?: {
    asset: {
      url: string;
    };
  };
  details?: string[];
  ctaText: string;
  ctaLink: string;
}

export interface LandingPageContent {
  settings: Settings | null;
  home: HomeContent | null;
  products: Product[];
}

/**
 * Fetch all landing page content in a single request.
 * Returns settings, home content, and products.
 */
export async function getLandingPageContent(): Promise<LandingPageContent> {
  if (!isSanityConfigured()) {
    return { settings: null, home: null, products: [] };
  }

  try {
    const client = getClient();
    if (!client) return { settings: null, home: null, products: [] };
    return await client.fetch<LandingPageContent>(landingPageQuery);
  } catch (error) {
    console.error("Error fetching landing page content:", error);
    return { settings: null, home: null, products: [] };
  }
}
