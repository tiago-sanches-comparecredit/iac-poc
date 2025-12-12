import { defineField, defineType } from "sanity";

/**
 * Product schema - simplified version inspired by cc-cms card schema.
 * Contains essential fields: name, slug, image, details, and CTA.
 */
export const product = defineType({
  name: "product",
  title: "Product",
  type: "document",
  fields: [
    defineField({
      name: "name",
      title: "Product Name",
      type: "string",
      description: "The name of the product",
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: "slug",
      title: "Slug",
      type: "slug",
      description: "URL-friendly identifier for the product",
      options: {
        source: "name",
        maxLength: 96,
      },
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: "image",
      title: "Product Image",
      type: "image",
      description: "Main product image (card art, product photo, etc.)",
    }),
    defineField({
      name: "details",
      title: "Details",
      type: "array",
      description: "Key product details or features (bullet points)",
      of: [{ type: "string" }],
      validation: (Rule) => Rule.max(5),
    }),
    defineField({
      name: "ctaText",
      title: "CTA Button Text",
      type: "string",
      description: "Text for the apply/action button",
      initialValue: "Learn More",
    }),
    defineField({
      name: "ctaLink",
      title: "CTA Link",
      type: "string",
      description: "URL for the CTA button (can be external link)",
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: "order",
      title: "Display Order",
      type: "number",
      description: "Order in which this product appears in the list (lower = first)",
      initialValue: 0,
    }),
  ],
  orderings: [
    {
      title: "Display Order",
      name: "orderAsc",
      by: [{ field: "order", direction: "asc" }],
    },
    {
      title: "Name A-Z",
      name: "nameAsc",
      by: [{ field: "name", direction: "asc" }],
    },
  ],
  preview: {
    select: {
      title: "name",
      subtitle: "ctaText",
      media: "image",
    },
    prepare({ title, subtitle, media }) {
      return {
        title: title || "Untitled Product",
        subtitle: subtitle || "No CTA text",
        media,
      };
    },
  },
});
