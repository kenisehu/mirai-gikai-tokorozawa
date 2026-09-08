import type { Metadata } from "next";
import Link from "next/link";
import {
  LegalPageLayout,
  LegalParagraph,
  LegalSectionTitle,
} from "@/components/layouts/legal-page-layout";
import { siteConfig } from "@/config/site.config";

export const metadata: Metadata = {
  title: `更新履歴・情報源 | ${siteConfig.siteName}`,
  description: "掲載情報の出典、確認日、主な修正の履歴",
};

const updates = [
  {
    date: "2026年9月8日",
    title: "掲載範囲と審議状況を明確化",
    detail:
      "掲載対象が令和8年第5回（9月）定例会議の市長提出41案件であることを明記し、日程・審議結果・過去会議への導線を追加しました。",
  },
  {
    date: "2026年9月8日",
    title: "市民向け見出しを追加",
    detail:
      "一覧と詳細ページで、解説の要点を最初に表示し、正式名称を併記する形に変更しました。",
  },
  {
    date: "2026年9月4日",
    title: "41案件の解説を公開",
    detail:
      "所沢市の議案本文・説明資料をもとに、やさしい解説と詳しい解説を公開しました。",
  },
] as const;

export default function UpdatesPage() {
  return (
    <LegalPageLayout
      title="更新履歴・情報源"
      enLabel="SOURCES & UPDATES"
      description="何を根拠に、いつ、どのように更新したかを確認できます。"
      className="pt-24 md:pt-12"
    >
      <section className="space-y-3 rounded-2xl bg-mirai-surface-gray p-5">
        <LegalSectionTitle>主な一次情報</LegalSectionTitle>
        <LegalParagraph>
          議案名・議案番号・担当課・PDFは、
          <Link
            href={siteConfig.councilBillsDetailUrl}
            target="_blank"
            rel="noreferrer"
            className="font-bold text-primary-accent underline underline-offset-4"
          >
            所沢市「市長提出議案」
          </Link>
          を確認しています。日程・審議結果・一般質問・委員会情報は、所沢市議会の公式サイトを確認しています。
        </LegalParagraph>
        <p className="text-xs text-mirai-text-note">最新確認日：2026年9月8日</p>
      </section>
      <section className="space-y-5">
        <LegalSectionTitle>主な更新履歴</LegalSectionTitle>
        <ol className="space-y-4">
          {updates.map((update) => (
            <li
              key={`${update.date}-${update.title}`}
              className="border-l-2 border-primary pl-4"
            >
              <time className="text-xs font-bold text-mirai-text-note">
                {update.date}
              </time>
              <h3 className="mt-1 font-bold text-mirai-text">{update.title}</h3>
              <p className="mt-1 text-sm leading-6 text-mirai-text-secondary">
                {update.detail}
              </p>
            </li>
          ))}
        </ol>
      </section>
    </LegalPageLayout>
  );
}
