import { ArrowLeft, ExternalLink } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Container } from "@/components/layouts/container";
import { routes } from "@/lib/routes";
import { findTokorozawaSessionArticle } from "../../shared/tokorozawa-session-articles";
import { getArchiveBills } from "../../shared/utils/archive-bills";

export function ArchiveBillPage({
  slug,
  billId,
}: {
  slug: string;
  billId: string;
}) {
  const session = findTokorozawaSessionArticle(slug);
  const bill = getArchiveBills(slug).find((item) => item.id === billId);
  if (!session || !bill) notFound();
  return (
    <Container>
      <main className="mx-auto max-w-3xl py-10 sm:py-16">
        <Link
          href={routes.sessionArticle(slug) as Route}
          className="inline-flex items-center gap-1 text-primary"
        >
          <ArrowLeft className="size-4" />
          {session.name}へ
        </Link>
        <p className="mt-8 font-bold text-primary">{bill.number}・審議終了</p>
        <h1 className="mt-3 text-3xl font-bold leading-tight">
          {bill.headline}
        </h1>
        <p className="mt-4 text-sm text-muted-foreground">
          正式名称：{bill.title}
        </p>
        <section className="mt-8 rounded-2xl border bg-white p-6">
          <h2 className="text-xl font-bold">何を決める議案？</h2>
          <p className="mt-4 leading-8">{bill.explanation}</p>
        </section>
        <section className="mt-8 rounded-2xl border bg-white p-6">
          <h2 className="text-xl font-bold">審議の結果</h2>
          <p className="mt-4 text-2xl font-bold">{bill.result}</p>
          <p className="mt-3">付託先：{bill.committee}</p>
          <p className="mt-4 text-sm leading-7 text-muted-foreground">
            結果と付託先は所沢市議会の結果表で確認しています。質疑・答弁の個別の要約は未掲載です。可決・同意は議会の判断を示し、事業の完了やサービスの開始を意味するものではありません。
          </p>
          <Link
            href={bill.resultUrl as Route}
            target="_blank"
            rel="noreferrer"
            className="mt-4 inline-flex items-center gap-1 text-primary underline"
          >
            この議案の公式結果表
            <ExternalLink className="size-4" />
          </Link>
        </section>
        <section className="mt-8 space-y-3">
          <h2 className="text-xl font-bold">根拠を確認する</h2>
          <p>
            <Link
              href={bill.pdfUrl as Route}
              target="_blank"
              rel="noreferrer"
              className="text-primary underline"
            >
              {bill.number}の公式議案PDF
            </Link>
          </p>
          {bill.supportingPdfUrl && (
            <p>
              <Link
                href={bill.supportingPdfUrl as Route}
                target="_blank"
                rel="noreferrer"
                className="text-primary underline"
              >
                市が作成した説明資料PDF
              </Link>
            </p>
          )}
          <p className="text-xs leading-6 text-muted-foreground">
            確認日：2026年9月9日。解説は公式資料を基に当サイトが作成した要約で、市の公式見解ではありません。個別の申請や制度の利用は最新の市の案内をご確認ください。
          </p>
        </section>
      </main>
    </Container>
  );
}
