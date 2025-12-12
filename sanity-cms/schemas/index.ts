/**
 * Schema index - exports all content schemas for Sanity Studio.
 * Add new schemas here to register them with the CMS.
 */

import { settings } from "./settings";
import { home } from "./home";
import { product } from "./product";

export const schemaTypes = [settings, home, product];
