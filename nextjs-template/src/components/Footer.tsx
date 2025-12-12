import { siteConfig } from "@/config/site";
import Link from "next/link";

/**
 * Footer component with site information and links.
 */
export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-gray-200 bg-gray-50">
      <div className="container mx-auto px-4 py-12">
        <div className="flex flex-col items-center justify-between gap-6 sm:flex-row">
          <div className="flex items-center gap-2">
            <div
              className="flex h-8 w-8 items-center justify-center rounded-lg text-white font-bold"
              style={{ backgroundColor: siteConfig.primaryColor }}
            >
              {siteConfig.name.charAt(0)}
            </div>
            <span className="text-lg font-semibold text-gray-900">
              {siteConfig.name}
            </span>
          </div>

          <nav className="flex items-center gap-6">
            <Link
              href="/privacy"
              className="text-sm text-gray-600 hover:text-gray-900 transition-colors"
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              className="text-sm text-gray-600 hover:text-gray-900 transition-colors"
            >
              Terms of Service
            </Link>
            <Link
              href="/contact"
              className="text-sm text-gray-600 hover:text-gray-900 transition-colors"
            >
              Contact
            </Link>
          </nav>
        </div>

        <div className="mt-8 border-t border-gray-200 pt-8 text-center">
          <p className="text-sm text-gray-500">
            © {currentYear} {siteConfig.name}. All rights reserved.
          </p>
          <p className="mt-2 text-xs text-gray-400">
            Vertical: {siteConfig.vertical}
          </p>
        </div>
      </div>
    </footer>
  );
}
