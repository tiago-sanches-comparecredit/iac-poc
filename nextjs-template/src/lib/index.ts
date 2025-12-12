/**
 * Central export for library utilities.
 */

export { getClient, urlFor, isSanityConfigured } from "./sanity";
export {
  settingsQuery,
  homeQuery,
  productsQuery,
  landingPageQuery,
} from "./queries";
export {
  getLandingPageContent,
  type Settings,
  type HomeContent,
  type Product,
  type LandingPageContent,
} from "./sanity-fetch";
