import { siteConfig } from "@/config/site";
import Image from "next/image";
import Link from "next/link";

interface HeaderProps {
  siteName?: string;
  logoUrl?: string;
  logoAlt?: string;
}

/**
 * Header component with site logo and navigation.
 * Logo and site name can come from Sanity or fallback to siteConfig.
 */
export function Header({ siteName, logoUrl, logoAlt }: HeaderProps) {
  const displayName = siteName || siteConfig.name;

  return (
    <header className="sticky top-0 z-50 w-full border-b border-gray-200 bg-white/80 backdrop-blur-sm">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/" className="flex items-center gap-2">
          {logoUrl ? (
            <Image
              src={logoUrl}
              alt={logoAlt || displayName}
              width={32}
              height={32}
              className="h-8 w-auto"
            />
          ) : (
            <div
              className="flex h-8 w-8 items-center justify-center rounded-lg text-white font-bold"
              style={{ backgroundColor: siteConfig.primaryColor }}
            >
              {displayName.charAt(0)}
            </div>
          )}
          <span className="text-xl font-semibold text-gray-900">
            {displayName}
          </span>
        </Link>

        <nav className="hidden md:flex items-center gap-6">
          <Link
            href="#products"
            className="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors"
          >
            Products
          </Link>
          <Link
            href="#products"
            className="rounded-full px-4 py-2 text-sm font-medium text-white transition-colors hover:opacity-90"
            style={{ backgroundColor: siteConfig.primaryColor }}
          >
            Get Started
          </Link>
        </nav>
      </div>
    </header>
  );
}
