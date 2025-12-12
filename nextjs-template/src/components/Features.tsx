import { siteConfig } from "@/config/site";

interface Feature {
  title: string;
  description: string;
  icon: string;
}

interface FeaturesProps {
  // Features can come from CMS or use defaults
  features?: Feature[];
}

// Default features - will be replaced by CMS data when available
const defaultFeatures: Feature[] = [
  {
    title: "Easy to Use",
    description:
      "Get started in minutes with our intuitive interface. No complicated setup required.",
    icon: "⚡",
  },
  {
    title: "Secure & Reliable",
    description:
      "Your data is protected with enterprise-grade security and 99.9% uptime guarantee.",
    icon: "🔒",
  },
  {
    title: "24/7 Support",
    description:
      "Our dedicated support team is always here to help you succeed.",
    icon: "💬",
  },
];

/**
 * Features section displaying key product benefits.
 * Can receive features from CMS or use hardcoded defaults.
 */
export function Features({ features = defaultFeatures }: FeaturesProps) {
  return (
    <section id="features" className="py-20 sm:py-32">
      <div className="container mx-auto px-4">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            Why Choose {siteConfig.name}?
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Discover the features that make us the best choice for your needs.
          </p>
        </div>

        <div className="mx-auto mt-16 grid max-w-5xl grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <div
              key={index}
              className="relative rounded-2xl border border-gray-200 bg-white p-8 shadow-sm transition-shadow hover:shadow-md"
            >
              <div
                className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl text-2xl"
                style={{ backgroundColor: `${siteConfig.primaryColor}20` }}
              >
                {feature.icon}
              </div>

              <h3 className="text-lg font-semibold text-gray-900">
                {feature.title}
              </h3>

              <p className="mt-2 text-gray-600">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
