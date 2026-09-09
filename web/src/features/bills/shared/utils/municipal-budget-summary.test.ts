import { describe, expect, it } from "vitest";
import {
  getMunicipalBudgetSummary,
  TOKOROZAWA_BUDGET_SUMMARIES,
} from "./municipal-budget-summary";

describe("getMunicipalBudgetSummary", () => {
  it("狭山ケ丘は単年度予算ではなく継続費総額の変更と明示する", () => {
    const summary = getMunicipalBudgetSummary(
      "令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）"
    );
    expect(summary?.changeLabel).toBe("事業総額の増額");
    expect(summary?.note).toContain("今年度だけの追加予算ではありません");
    expect(summary?.note).toContain("2億7,500万円は変わりません");
  });
  it("確認済みの補正予算5件だけを登録している", () => {
    expect(Object.keys(TOKOROZAWA_BUDGET_SUMMARIES)).toHaveLength(5);
  });

  it("詳しい解説にも同じ図解データを返す", () => {
    expect(
      getMunicipalBudgetSummary(
        "令和8年度所沢市介護保険特別会計補正予算（第1号）（詳しい解説）"
      )?.amountLabel
    ).toBe("約9.8億円");
  });

  it("数値未確認の決算案件には図解を出さない", () => {
    expect(
      getMunicipalBudgetSummary(
        "令和7年度所沢市一般会計歳入歳出決算の認定について"
      )
    ).toBeNull();
  });
});
