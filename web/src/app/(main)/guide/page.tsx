import { ExternalLink } from "lucide-react";
import type { Metadata } from "next";
import Link from "next/link";
import {
  LegalPageLayout,
  LegalParagraph,
  LegalSectionTitle,
} from "@/components/layouts/legal-page-layout";
import { siteConfig } from "@/config/site.config";

export const metadata: Metadata = {
  title: `議会の見かた | ${siteConfig.siteName}`,
  description: "所沢市議会の審議の流れと、公式情報への案内",
};

const processSteps = [
  ["1. 提案・説明", "市長が議案を提出し、目的や内容を説明します。"],
  ["2. 議案質疑", "議員が内容や費用、効果などを市に質問します。"],
  ["3. 委員会審査", "分野別の委員会で資料を確認し、詳しく審査します。"],
  ["4. 討論・採決", "賛成・反対の意見を述べた後、本会議で結論を出します。"],
] as const;

const officialLinks = [
  ["今月の議会日程", siteConfig.currentMeeting.scheduleUrl],
  [
    "一般質問の通告",
    "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/202609ippan.html",
  ],
  [
    "委員会の活動",
    "https://www.city.tokorozawa.saitama.jp/shigikai/tokubetuiinkaijyouhou/index.html",
  ],
  [
    "委員会名簿",
    "https://www.city.tokorozawa.saitama.jp/shigikai/shokai/iinkaimeibo.html",
  ],
  [
    "議会中継",
    "https://smart.discussvision.net/smart/tenant/tokorozawa/WebView/rd/council_1.html",
  ],
  [
    "令和8年度当初予算",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/zaisei/yosan/R8toushoyosan.html",
  ],
] as const;

export default function GuidePage() {
  return (
    <LegalPageLayout
      title="所沢市議会の見かた"
      enLabel="GUIDE"
      description="議案が決まるまでの流れと、議案以外の議会情報をまとめました。"
      className="pt-24 md:pt-12"
    >
      <section className="space-y-4">
        <LegalSectionTitle>議案が決まるまで</LegalSectionTitle>
        <div className="grid gap-3 sm:grid-cols-2">
          {processSteps.map(([title, description]) => (
            <div
              key={title}
              className="rounded-xl border border-mirai-border bg-white p-4"
            >
              <h3 className="font-bold text-primary-accent">{title}</h3>
              <p className="mt-2 text-sm leading-6 text-mirai-text-secondary">
                {description}
              </p>
            </div>
          ))}
        </div>
        <LegalParagraph>
          所沢市議会は通年会期制です。現在の9月定例会議では、9月7日・8日に委員会審査、14日に市長提出議案の採決が予定されています。
        </LegalParagraph>
      </section>
      <section className="space-y-4">
        <LegalSectionTitle>議案以外の公式情報</LegalSectionTitle>
        <div className="grid gap-3 sm:grid-cols-2">
          {officialLinks.map(([label, url]) => (
            <Link
              key={label}
              href={url}
              target="_blank"
              rel="noreferrer"
              className="flex items-center justify-between rounded-xl bg-mirai-surface-gray p-4 font-bold text-primary-accent hover:opacity-80"
            >
              {label}
              <ExternalLink className="size-4" />
            </Link>
          ))}
        </div>
      </section>
    </LegalPageLayout>
  );
}
