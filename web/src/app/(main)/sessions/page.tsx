import { ExternalLink } from "lucide-react";
import type { Metadata } from "next";
import Link from "next/link";
import {
  LegalPageLayout,
  LegalParagraph,
} from "@/components/layouts/legal-page-layout";
import { siteConfig } from "@/config/site.config";

export const metadata: Metadata = {
  title: `会議一覧 | ${siteConfig.siteName}`,
  description: "所沢市議会の現在の会議と過去の市長提出議案一覧",
};

const sessions = [
  [
    "令和8年第5回（9月）定例会議",
    "掲載中・41案件",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html",
  ],
  [
    "令和8年第4回（6月）定例会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai4kai.html",
  ],
  [
    "令和8年第3回（5月）臨時会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai3kairinjikai.html",
  ],
  [
    "令和8年第2回（2月）定例会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai2kai.html",
  ],
  [
    "令和8年第1回（2月）臨時会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai1kai.html",
  ],
  [
    "令和7年第5回（12月）定例会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa7nendai5kai.html",
  ],
  [
    "令和7年第4回（9月）定例会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa7nendai4kai.html",
  ],
  [
    "令和7年第3回（6月）定例会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa7nendai3kai.html",
  ],
  [
    "令和7年第2回（5月）臨時会議",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa7nendai2kai.html",
  ],
  [
    "令和7年第1回定例会",
    "公式資料",
    "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa7nendai1kaiteireikai.html",
  ],
] as const;

export default function SessionsPage() {
  return (
    <LegalPageLayout
      title="所沢市議会の会議一覧"
      enLabel="SESSIONS"
      description="現在の掲載範囲と、過去に所沢市が公開した市長提出議案を確認できます。"
      className="pt-24 md:pt-12"
    >
      <section className="rounded-2xl border border-primary/20 bg-mirai-surface-gray p-5">
        <h2 className="text-lg font-bold">このサイトで解説している範囲</h2>
        <LegalParagraph className="mt-2">
          現在は「令和8年第5回（9月）定例会議」の市長提出41案件を掲載しています。請願・陳情、議員提出議案、一般質問は現時点の掲載対象に含みません。
        </LegalParagraph>
      </section>
      <div className="space-y-3">
        {sessions.map(([name, status, url]) => (
          <Link
            key={name}
            href={url}
            target="_blank"
            rel="noreferrer"
            className="flex items-center justify-between gap-4 rounded-xl border border-mirai-border bg-white p-4 transition-colors hover:bg-mirai-surface-gray"
          >
            <span>
              <span className="block font-bold text-mirai-text">{name}</span>
              <span className="mt-1 block text-xs text-mirai-text-secondary">
                {status}
              </span>
            </span>
            <ExternalLink className="size-4 shrink-0 text-primary-accent" />
          </Link>
        ))}
      </div>
      <p className="text-xs leading-6 text-mirai-text-note">
        過去会議は、まず公式資料へ迷わず到達できる形で公開しています。解説記事は確認が完了した会議から順次追加します。
      </p>
    </LegalPageLayout>
  );
}
