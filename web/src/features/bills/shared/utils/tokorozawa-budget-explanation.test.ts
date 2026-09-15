import { describe, expect, it } from "vitest";
import { getTokorozawaBudgetExplanation } from "./tokorozawa-budget-explanation";

const metadata = {
  municipality_name: "所沢市",
  meeting_name: "令和8年第5回(9月)定例会議市長提出議案",
  bill_number: "議案第85号",
};

describe("getTokorozawaBudgetExplanation", () => {
  it.each([
    85, 86, 87, 88, 89,
  ])("議案%sに具体的な解説・原文・確認日がある", (n) => {
    const content = getTokorozawaBudgetExplanation({
      ...metadata,
      bill_number: `議案第${n}号`,
    });
    expect(content).toContain("市民生活との関係");
    expect(content).toContain("R8-siryou-085-089.pdf#page=");
    expect(content).toContain("2026年9月15日");
  });

  it("他市・別会議・未対応の議案は元の本文を使う", () => {
    expect(getTokorozawaBudgetExplanation()).toBeNull();
    expect(
      getTokorozawaBudgetExplanation({
        ...metadata,
        municipality_name: "福岡市",
      })
    ).toBeNull();
    expect(
      getTokorozawaBudgetExplanation({
        ...metadata,
        meeting_name: "令和9年第5回(9月)定例会議市長提出議案",
      })
    ).toBeNull();
    expect(
      getTokorozawaBudgetExplanation({ ...metadata, bill_number: "議案第90号" })
    ).toBeNull();
  });

  it("複数年度の増額と今年度の予算を区別する", () => {
    const content = getTokorozawaBudgetExplanation({
      ...metadata,
      bill_number: "議案第86号",
    });
    expect(content).toContain("22億8,657万4千円");
    expect(content).toContain("2億7,500万円で変更なし");
    expect(content).toContain("令和10年度から令和15年度");
  });

  it("介護保険の追加額を給付拡大と誤認させず、4項目を説明する", () => {
    const content = getTokorozawaBudgetExplanation({
      ...metadata,
      bill_number: "議案第88号",
    });
    for (const amount of [
      "3,610万円",
      "4億8,003万円",
      "3億515万5千円",
      "1億6,116万3千円",
      "9億8,244万8千円",
    ]) {
      expect(content).toContain(amount);
    }
    expect(content).toContain(
      "全額が新しい介護サービスに使われるわけではありません"
    );
  });
});
