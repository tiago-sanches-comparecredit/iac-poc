import { defineField, defineType } from "sanity";

/**
 * Home schema - singleton document for the landing page content.
 * Contains hero section with title, subtitle, and CTA.
 */
export const home = defineType({
  name: "home",
  title: "Home Page",
  type: "document",
  fields: [
    defineField({
      name: "title",
      title: "Hero Title",
      type: "string",
      description: "The main headline displayed in the hero section",
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: "subtitle",
      title: "Hero Subtitle",
      type: "text",
      description: "Supporting text below the main headline",
      rows: 3,
    }),
    defineField({
      name: "ctaText",
      title: "CTA Button Text",
      type: "string",
      description: "Text for the primary call-to-action button",
      initialValue: "Get Started",
    }),
    defineField({
      name: "ctaLink",
      title: "CTA Button Link",
      type: "string",
      description: "URL or path for the CTA button",
      initialValue: "#products",
    }),
  ],
  preview: {
    select: {
      title: "title",
      subtitle: "subtitle",
    },
    prepare({ title, subtitle }) {
      return {
        title: title || "Home Page",
        subtitle: subtitle ? subtitle.substring(0, 50) + "..." : "Landing page content",
      };
    },
  },
});
