import { describe, expect, it } from "vitest";
import { getMunicipalResultStatus } from "./municipal-result-status";

describe("getMunicipalResultStatus", () => {
  it("登録された議決結果を反映する", () => {
    for (const result of [
      "原案可決",
      "修正可決",
      "認定",
      "同意する",
      "回答する",
      " 可決 ",
    ])
      expect(getMunicipalResultStatus(result, "introduced")).toBe("enacted");
    for (const result of ["否決", "不認定", "不同意"])
      expect(getMunicipalResultStatus(result, "introduced")).toBe("rejected");
  });
  it("未登録や継続審査では議決済みと決めつけない", () => {
    for (const result of [
      "認定予定",
      "可決か未確認",
      "回答する予定",
      "決算特別委員会に付託（最終結果未確認）",
    ])
      expect(getMunicipalResultStatus(result, "introduced")).toBe("introduced");
    expect(getMunicipalResultStatus(null, "introduced")).toBe("introduced");
    expect(getMunicipalResultStatus("継続審査", "in_originating_house")).toBe(
      "in_originating_house"
    );
  });
});
