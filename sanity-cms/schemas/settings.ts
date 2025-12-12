import { defineField, defineType } from "sanity";

/**
 * Settings schema - singleton document for global site settings.
 * Contains logo and basic site configuration.
 */
export const settings = defineType({
  name: "settings",
  title: "Settings",
  type: "document",
  fields: [
    defineField({
      name: "siteName",
      title: "Site Name",
      type: "string",
      description: "The name of the site (shown in header and title)",
      validation: (Rule) => Rule.required(),
    }),
    defineField({
      name: "logo",
      title: "Logo",
      type: "image",
      description: "Site logo displayed in the navigation bar",
      options: {
        hotspot: true,
      },
    }),
    defineField({
      name: "logoAlt",
      title: "Logo Alt Text",
      type: "string",
      description: "Alternative text for the logo (for accessibility)",
    }),
  ],
  preview: {
    select: {
      title: "siteName",
      media: "logo",
    },
    prepare({ title, media }) {
      return {
        title: title || "Site Settings",
        subtitle: "Global settings",
        media,
      };
    },
  },
});
