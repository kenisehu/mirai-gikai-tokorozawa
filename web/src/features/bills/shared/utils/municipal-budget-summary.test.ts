import { describe, expect, it } from "vitest";
import {
  getMunicipalBudgetSummary,
  TOKOROZAWA_BUDGET_SUMMARIES,
} from "./municipal-budget-summary";

describe("getMunicipalBudgetSummary", () => {
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
