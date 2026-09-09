import { SessionArticlePage } from "@/features/session-archive/server/components/session-article-page";

export default async function Page({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  return <SessionArticlePage slug={slug} />;
}
