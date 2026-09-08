import type { Metadata } from "next";
import Link from "next/link";
import {
  LegalPageLayout,
  LegalParagraph,
  LegalSectionTitle,
} from "@/components/layouts/legal-page-layout";
import { siteConfig } from "@/config/site.config";

export const metadata: Metadata = {
  title: `よくある質問 | ${siteConfig.siteName}`,
  description: `${siteConfig.siteName}に関するよくある質問`,
};

const faqs = [
  {
    question: `${siteConfig.siteName}とは何ですか？`,
    answer:
      "所沢市議会の議案を、市民が短時間で理解しやすい言葉にして紹介する非公式サイトです。議案名だけでは分かりにくい変更点や、市民生活との関係を整理しています。",
  },
  {
    question: "所沢市や所沢市議会の公式サイトですか？",
    answer:
      "いいえ。チームみらいが公開した「みらい議会」をもとに、市民が運営している非公式サイトです。所沢市、所沢市議会、チームみらいの公式サービスではありません。",
  },
  {
    question: "議案の情報はどこから取得していますか？",
    answer:
      "所沢市が公開している市長提出議案などの公式資料をもとに掲載しています。各議案ページから元の資料を確認できます。",
  },
  {
    question: "解説は正確ですか？",
    answer:
      "公式資料をもとにAIも活用して作成していますが、正確性や完全性を保証するものではありません。重要な判断には、必ずリンク先の公式資料をご確認ください。",
  },
  {
    question: "「やさしく」と「詳しく」は何が違いますか？",
    answer:
      "「やさしく」は要点を短くつかみたい方向け、「詳しく」は背景や変更内容まで確認したい方向けです。画面上部からいつでも切り替えられます。",
  },
  {
    question: "掲載内容に誤りを見つけたらどうすればよいですか？",
    answer:
      "ページ下部の「問題を報告する」からお知らせください。確認して、必要に応じて修正します。",
  },
];

export default function FaqPage() {
  return (
    <LegalPageLayout
      title="よくある質問"
      enLabel="FAQ"
      description="このサイトの見方や、掲載情報についてまとめています。"
      className="pt-24 md:pt-12"
    >
      {faqs.map((faq) => (
        <section key={faq.question} className="space-y-3">
          <LegalSectionTitle>{faq.question}</LegalSectionTitle>
          <LegalParagraph>{faq.answer}</LegalParagraph>
        </section>
      ))}
      <section className="rounded-2xl bg-mirai-surface-gray p-5">
        <LegalSectionTitle>公式情報を確認する</LegalSectionTitle>
        <LegalParagraph className="mt-3">
          <Link
            href={siteConfig.councilBillsDetailUrl}
            target="_blank"
            rel="noreferrer"
            className="font-bold text-primary-accent underline underline-offset-4"
          >
            所沢市「市長提出議案」ページ
          </Link>
        </LegalParagraph>
      </section>
    </LegalPageLayout>
  );
}
