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
    purpose: "子育て・農業支援、税金の還付など",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）":
    {
      amountLabel: "約23億円",
      changeLabel: "事業総額の増額",
      purpose: "狭山ケ丘の土地区画整理事業（複数年度の継続費）",
      note: "継続費の総額を153億1,367万5千円から176億24万9千円へ、22億8,657万4千円増額し、期間を5年延長する案です。令和8年度の年割額2億7,500万円は変わりません。今年度だけの追加予算ではありません。",
    },
  "令和8年度所沢市国民健康保険特別会計補正予算（第1号）": {
    amountLabel: "約2億円",
    changeLabel: "追加",
    purpose: "前年度繰越金を財政調整基金へ積立",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市介護保険特別会計補正予算（第1号）": {
    amountLabel: "約9.8億円",
    changeLabel: "追加",
    purpose: "基金積立・前年度精算・システム改修など",
    note: "補正予算額。表示額は市の議案資料を基に億円単位で丸めています。",
  },
  "令和8年度所沢市後期高齢者医療特別会計補正予算（第1号）": {
    amountLabel: "約4,330万円",
    changeLabel: "追加",
    purpose: "前年度分の精算・広域連合への納付など",
    note: "補正予算額。表示額は市の議案資料を基に万円単位で丸めています。",
  },
};

export function getMunicipalBudgetSummary(
  officialTitle: string
): MunicipalBudgetSummary | null {
  const normalized = officialTitle.replace(/（詳しい解説）$/, "");
  return TOKOROZAWA_BUDGET_SUMMARIES[normalized] ?? null;
}
