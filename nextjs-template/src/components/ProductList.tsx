import { ProductCard, type Product } from "./ProductCard";

interface ProductListProps {
  products: Product[];
}

/**
 * ProductList component - displays a list of products.
 * Inspired by cc-www CardList styling.
 */
export function ProductList({ products }: ProductListProps) {
  if (!products || products.length === 0) {
    return (
      <section id="products" className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <p className="text-center text-gray-500">
            No products available. Add products in Sanity CMS.
          </p>
        </div>
      </section>
    );
  }

  return (
    <section id="products" className="py-16 bg-gray-50">
      <div className="container mx-auto px-4">
        <div className="max-w-4xl mx-auto">
          {products.map((product, index) => (
            <ProductCard
              key={product._id}
              product={product}
              featured={index === 0}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
