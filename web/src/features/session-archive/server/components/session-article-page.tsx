import { ArrowLeft, ExternalLink, FileCheck2 } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Container } from "@/components/layouts/container";
import { Button } from "@/components/ui/button";
import { routes } from "@/lib/routes";
import { findTokorozawaSessionArticle } from "../../shared/tokorozawa-session-articles";

export function SessionArticlePage({ slug }: { slug: string }) {
  const article = findTokorozawaSessionArticle(slug);
  if (!article) notFound();

  return (
    <Container>
      <main className="mx-auto max-w-3xl py-10 sm:py-16">
        <Link
          href={routes.sessions()}
          className="inline-flex items-center gap-1 text-sm font-bold text-primary"
        >
          <ArrowLeft className="size-4" />
          会議一覧へ
        </Link>
        <p className="mt-8 text-sm font-bold text-primary">過去会議の記事</p>
        <h1 className="mt-2 text-3xl font-bold">{article.name}</h1>
        <p className="mt-2 text-sm text-muted-foreground">{article.dates}</p>
        <p className="mt-6 text-lg leading-8">{article.overview}</p>
        <section className="mt-10 rounded-2xl border bg-white p-5 shadow-sm sm:p-7">
          <div className="flex items-center gap-2">
            <FileCheck2 className="size-5 text-primary" />
            <h2 className="text-xl font-bold">審議された内容</h2>
          </div>
          <p className="mt-4 text-4xl font-black">
            {article.proposalCount}
            <span className="ml-1 text-base font-bold">件</span>
          </p>
          <div className="mt-6 grid gap-3 sm:grid-cols-2">
            {article.breakdown.map((item) => (
              <div
                key={item.label}
                className="flex items-center justify-between rounded-xl bg-muted/40 px-4 py-3"
              >
                <span className="text-sm">{item.label}</span>
                <span className="font-bold">{item.count}件</span>
              </div>
            ))}
          </div>
        </section>
        <section className="mt-8">
          <h2 className="text-xl font-bold">注目されたテーマ</h2>
          <ul className="mt-4 grid gap-3 sm:grid-cols-2">
            {article.highlights.map((item) => (
              <li
                key={item}
                className="rounded-xl border bg-white p-4 font-medium"
              >
                {item}
              </li>
            ))}
          </ul>
        </section>
        <section className="mt-10 rounded-2xl bg-muted/40 p-5">
          <h2 className="font-bold">一次資料で詳しく確認する</h2>
          <div className="mt-4 flex flex-wrap gap-3">
            <Button asChild variant="outline" size="sm">
              <Link
                href={article.officialBillsUrl as Route}
                target="_blank"
                rel="noreferrer"
              >
                議案・PDF
                <ExternalLink />
              </Link>
            </Button>
            <Button asChild variant="outline" size="sm">
              <Link
                href={article.officialResultsUrl as Route}
                target="_blank"
                rel="noreferrer"
              >
                審議結果
                <ExternalLink />
              </Link>
            </Button>
            <Button asChild variant="outline" size="sm">
              <Link
                href={article.officialMeetingUrl as Route}
                target="_blank"
                rel="noreferrer"
              >
                会議全体
                <ExternalLink />
              </Link>
            </Button>
          </div>
        </section>
        <p className="mt-6 text-xs leading-6 text-muted-foreground">
          件数・内訳・結果は所沢市議会および所沢市の公式発表に基づいています。個別議案の市民向け解説は、一次資料との照合が済んだものから追加します。
        </p>
      </main>
    </Container>
  );
}
