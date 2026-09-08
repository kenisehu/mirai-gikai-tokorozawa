import { describe, expect, it } from "vitest";
import { getCitizenHeadline } from "./citizen-headline";

describe("getCitizenHeadline", () => {
  it("解説の最初の一文を見出しにする", () => {
    expect(
      getCitizenHeadline(
        "一般会計に2億円を追加します。子育て支援などに使います。",
        "一般会計補正予算"
      )
    ).toBe("一般会計に2億円を追加します");
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
