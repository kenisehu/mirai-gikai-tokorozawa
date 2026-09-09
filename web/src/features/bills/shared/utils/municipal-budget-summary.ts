export type MunicipalBudgetSummary = {
  amountLabel: string;
  changeLabel: string;
  purpose: string;
  note: string;
};

export const TOKOROZAWA_BUDGET_SUMMARIES: Readonly<
  Record<string, MunicipalBudgetSummary>
> = {
  "令和8年度所沢市一般会計補正予算（第2号）": {
    amountLabel: "約2.5億円",
    changeLabel: "追加",
    purpose: "新所沢パルコ跡地の調査など",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）":
    {
      amountLabel: "約23億円",
      changeLabel: "追加",
      purpose: "狭山ケ丘の土地区画整理事業",
      note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
    },
  "令和8年度所沢市国民健康保険特別会計補正予算（第1号）": {
    amountLabel: "約2億円",
    changeLabel: "追加",
    purpose: "国民健康保険の特別会計",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市介護保険特別会計補正予算（第1号）": {
    amountLabel: "約9.8億円",
    changeLabel: "追加",
    purpose: "介護保険の特別会計",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市後期高齢者医療特別会計補正予算（第1号）": {
    amountLabel: "約4,330万円",
    changeLabel: "追加",
    purpose: "後期高齢者医療の特別会計",
    note: "補正予算額。表示額は市の議案資料を基に万円単位で丸めています。",
  },
};

export function getMunicipalBudgetSummary(
  officialTitle: string
): MunicipalBudgetSummary | null {
  const normalized = officialTitle.replace(/（詳しい解説）$/, "");
  return TOKOROZAWA_BUDGET_SUMMARIES[normalized] ?? null;
}
