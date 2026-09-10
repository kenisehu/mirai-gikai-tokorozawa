export type SessionArticle = {
  slug: string;
  name: string;
  dates: string;
  proposalCount: number;
  overview: string;
  highlights: string[];
  breakdown: { label: string; count: number }[];
  officialMeetingUrl: string;
  officialBillsUrl: string;
  officialResultsUrl: string;
};

export const TOKOROZAWA_SESSION_ARTICLES: SessionArticle[] = [
  {
    slug: "2026-06",
    name: "令和8年第4回（6月）定例会議",
    dates: "2026年6月1日〜6月19日",
    proposalCount: 40,
    overview:
      "補正予算、公共施設へのLED一括導入、学校体育館の空調工事など、市長提出議案等40件が審議されました。",
    highlights: [
      "一般会計補正予算",
      "公共施設のLED一括導入",
      "学校用コンピュータの取得",
      "中学校体育館の空調工事",
      "保健医療特別委員会の設置",
    ],
    breakdown: [
      { label: "補正予算", count: 1 },
      { label: "条例改正", count: 3 },
      { label: "契約・契約変更", count: 7 },
      { label: "財産の取得", count: 2 },
      { label: "市道認定・廃止", count: 6 },
      { label: "人事関係", count: 21 },
    ],
    officialMeetingUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai4/index.html",
    officialBillsUrl:
      "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai4kai.html",
    officialResultsUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai4/R8_dai4kai_kekka.html",
  },
  {
    slug: "2026-02",
    name: "令和8年第2回（2月）定例会議",
    dates: "2026年2月18日〜3月24日",
    proposalCount: 42,
    overview:
      "令和8年度当初予算を中心に、市長提出議案42件が審議されました。当初案2件が否決された後、内容を変更して再提出された一般会計・病院事業会計予算が可決されています。",
    highlights: [
      "令和8年度当初予算",
      "一般会計予算案の否決と再提出案可決",
      "病院事業会計予算案の否決と再提出案可決",
      "所沢市保健所の整備",
      "乳児等通園支援",
    ],
    breakdown: [
      { label: "令和7年度補正予算", count: 6 },
      { label: "令和8年度当初予算", count: 12 },
      { label: "条例制定・改廃", count: 20 },
      { label: "財産取得・和解・市道", count: 3 },
      { label: "人事関係", count: 1 },
    ],
    officialMeetingUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai2/index.html",
    officialBillsUrl:
      "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai2kai.html",
    officialResultsUrl:
      "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai2/R8_dai2kai_kekka.html",
  },
];

export function findTokorozawaSessionArticle(slug: string) {
  return (
    TOKOROZAWA_SESSION_ARTICLES.find((article) => article.slug === slug) ?? null
  );
}
