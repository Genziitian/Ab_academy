import "server-only";
import { cache } from "react";

/** One clock reading per request, so every part of a page agrees on "now". */
export const requestNow = cache(() => Date.now());
