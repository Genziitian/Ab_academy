import type { MetadataRoute } from "next";
import { listCourseSlugs } from "@/lib/catalog";

const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://akhandbharatacademy.in";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const staticPaths = [
    { path: "", priority: 1 },
    { path: "/courses", priority: 0.9 },
    { path: "/for-students", priority: 0.8 },
    { path: "/about", priority: 0.6 },
    { path: "/contact", priority: 0.6 },
    { path: "/privacy", priority: 0.3 },
    { path: "/terms", priority: 0.3 },
  ];

  const slugs = await listCourseSlugs();
  const now = new Date();

  return [
    ...staticPaths.map(({ path, priority }) => ({
      url: `${siteUrl}${path}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority,
    })),
    ...slugs.map((slug) => ({
      url: `${siteUrl}/course/${slug}`,
      lastModified: now,
      changeFrequency: "weekly" as const,
      priority: 0.8,
    })),
  ];
}
