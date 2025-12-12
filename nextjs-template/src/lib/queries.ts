/**
 * GROQ queries for fetching content from Sanity CMS.
 * These queries are used by the data fetching functions.
 */

// Fetch site settings (singleton)
export const settingsQuery = `*[_type == "settings"][0] {
  siteName,
  logo {
    asset-> {
      url
    }
  },
  logoAlt
}`;

// Fetch home page content (singleton)
export const homeQuery = `*[_type == "home"][0] {
  title,
  subtitle,
  ctaText,
  ctaLink
}`;

// Fetch all products ordered by display order
export const productsQuery = `*[_type == "product"] | order(order asc) {
  _id,
  name,
  slug,
  image {
    asset-> {
      url
    }
  },
  details,
  ctaText,
  ctaLink,
  order
}`;

// Combined query for landing page (more efficient - single request)
export const landingPageQuery = `{
  "settings": *[_type == "settings"][0] {
    siteName,
    logo {
      asset-> {
        url
      }
    },
    logoAlt
  },
  "home": *[_type == "home"][0] {
    title,
    subtitle,
    ctaText,
    ctaLink
  },
  "products": *[_type == "product"] | order(order asc) {
    _id,
    name,
    slug,
    image {
      asset-> {
        url
      }
    },
    details,
    ctaText,
    ctaLink
  }
}`;

