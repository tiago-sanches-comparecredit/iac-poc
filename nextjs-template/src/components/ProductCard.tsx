import { siteConfig } from "@/config/site";
import Image from "next/image";
import Link from "next/link";

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

interface ProductCardProps {
  product: Product;
  featured?: boolean;
}

/**
 * ProductCard component - displays a single product in a card format.
 * Inspired by cc-www CardPanel styling.
 */
export function ProductCard({ product, featured = false }: ProductCardProps) {
  return (
    <div className="c-product-panel mb-5 break-words bg-white shadow-lg rounded-lg hover:shadow-xl transition-shadow">
      <div className="flex flex-col md:flex-row">
        {/* Left Section - Product Image */}
        <div className="md:w-1/4 p-4 flex items-center justify-center bg-gray-50 rounded-t-lg md:rounded-l-lg md:rounded-tr-none">
          {product.image?.asset?.url ? (
            <Image
              src={product.image.asset.url}
              alt={product.name}
              width={200}
              height={126}
              className="object-contain max-h-32"
            />
          ) : (
            <div
              className="w-48 h-32 rounded-lg flex items-center justify-center text-white text-2xl font-bold"
              style={{ backgroundColor: siteConfig.primaryColor }}
            >
              {product.name.charAt(0)}
            </div>
          )}
        </div>

        {/* Right Section - Content */}
        <div className="md:w-3/4 p-4 md:p-6 flex flex-col justify-between">
          {/* Top - Name and Details */}
          <div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              {product.name}
            </h3>

            {product.details && product.details.length > 0 && (
              <ul className="space-y-1 mb-4">
                {product.details.map((detail, index) => (
                  <li key={index} className="flex items-start text-sm text-gray-600">
                    <span
                      className="mr-2 mt-1 flex-shrink-0 w-1.5 h-1.5 rounded-full"
                      style={{ backgroundColor: siteConfig.primaryColor }}
                    />
                    {detail}
                  </li>
                ))}
              </ul>
            )}
          </div>

          {/* Bottom - CTA Button */}
          <div className="flex justify-end mt-4">
            <Link
              href={product.ctaLink}
              target={product.ctaLink.startsWith("http") ? "_blank" : undefined}
              rel={product.ctaLink.startsWith("http") ? "noopener noreferrer" : undefined}
              className="inline-flex items-center justify-center px-6 py-3 text-base font-semibold text-white rounded-lg transition-all hover:opacity-90 hover:shadow-md"
              style={{ backgroundColor: siteConfig.primaryColor }}
            >
              {product.ctaText}
              <svg
                className="ml-2 w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
