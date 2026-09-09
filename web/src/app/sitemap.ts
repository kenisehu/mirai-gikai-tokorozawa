import type { MetadataRoute } from "next";
import { getBills } from "@/features/bills/server/loaders/get-bills";
import { TOKOROZAWA_SESSION_ARTICLES } from "@/features/session-archive/shared/tokorozawa-session-articles";
import { getArchiveBills } from "@/features/session-archive/shared/utils/archive-bills";
import { routes } from "@/lib/routes";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.VERCEL_URL
    ? `https://${process.env.VERCEL_URL}`
    : "http://localhost:3000";

  const bills = await getBills();

  const billUrls = bills.map((bill) => ({
    url: `${baseUrl}${routes.billDetail(bill.id)}`,
    lastModified: new Date(bill.updated_at),
    changeFrequency: "weekly" as const,
    priority: 0.8,
  }));
  const archiveUpdatedAt = new Date("2026-09-09T00:00:00+09:00");
  const sessionUrls = TOKOROZAWA_SESSION_ARTICLES.flatMap((session) => [
    {
      url: `${baseUrl}${routes.sessionArticle(session.slug)}`,
      lastModified: archiveUpdatedAt,
      changeFrequency: "monthly" as const,
      priority: 0.7,
    },
    ...getArchiveBills(session.slug).map((bill) => ({
      url: `${baseUrl}${routes.archiveBill(session.slug, bill.id)}`,
      lastModified: archiveUpdatedAt,
      changeFrequency: "yearly" as const,
      priority: 0.6,
    })),
  ]);

  return [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: "daily" as const,
      priority: 1,
    },
    {
      url: `${baseUrl}${routes.billsList()}`,
      lastModified: new Date(),
      changeFrequency: "daily" as const,
      priority: 0.9,
    },
    {
      url: `${baseUrl}${routes.sessions()}`,
      lastModified: archiveUpdatedAt,
      changeFrequency: "monthly" as const,
      priority: 0.7,
    },
    ...billUrls,
    ...sessionUrls,
  ];
}
