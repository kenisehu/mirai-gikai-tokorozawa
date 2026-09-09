import { describe, expect, it } from "vitest";
import {
  getCitizenHeadline,
  TOKOROZAWA_CITIZEN_HEADLINES,
} from "./citizen-headline";

describe("getCitizenHeadline", () => {
  it("解説の最初の一文を見出しにする", () => {
    expect(
      getCitizenHeadline(
        "一般会計に2億円を追加します。子育て支援などに使います。",
        "一般会計補正予算"
      )
    ).toBe("一般会計に2億円を追加します");
  });

  it("所沢市の41案件すべてに個別見出しがある", () => {
    expect(Object.keys(TOKOROZAWA_CITIZEN_HEADLINES)).toHaveLength(41);
  });

  it("個別見出しを要約より優先する", () => {
    expect(
      getCitizenHeadline(
        "元の要約です。",
        "所沢市立みどり児童館の指定管理者の指定について"
      )
    ).toBe("みどり児童館の次期運営者を決める");
  });

  it("PDF由来の余分な空白を詰める", () => {
    expect(getCitizenHeadline("消防 団員制度を 導入します。", "条例改正")).toBe(
      "消防団員制度を導入します"
    );
  });

  it("解説がなければ公式名称を使う", () => {
    expect(getCitizenHeadline(null, "条例改正（詳しい解説）")).toBe("条例改正");
  });
});
