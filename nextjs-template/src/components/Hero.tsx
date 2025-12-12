import { siteConfig } from "@/config/site";

interface HeroProps {
  // Content comes from Sanity CMS
  title?: string;
  subtitle?: string;
  ctaText?: string;
  ctaLink?: string;
}

// Default content - shown only when Sanity has no data
const defaults = {
  title: `Welcome to ${siteConfig.name}`,
  subtitle: "Add your hero content in Sanity CMS to customize this section.",
};

/**
 * Hero section component for the landing page.
 * Content should come from Sanity CMS.
 */
export function Hero({
  title = defaults.title,
  subtitle = defaults.subtitle,
}: HeroProps) {
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-gray-50 to-white py-20 sm:py-32">
      {/* Background decoration */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `radial-gradient(circle at 25% 25%, ${siteConfig.primaryColor} 0%, transparent 50%)`,
        }}
      />

      <div className="container relative mx-auto px-4 text-center">
        <h1 className="mx-auto max-w-4xl text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
          {title}
        </h1>

        <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-gray-600">
          {subtitle}
        </p>
      </div>
    </section>
  );
}
