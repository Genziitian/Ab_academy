import type { MetadataRoute } from "next";

const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://akhandbharatacademy.in";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // The console is behind auth, but keep it out of the index regardless.
      disallow: ["/admin", "/admin/", "/auth/"],
    },
    sitemap: `${siteUrl}/sitemap.xml`,
  };
}
