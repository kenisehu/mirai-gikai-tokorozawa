import { describe, expect, it } from "vitest";
import { getMunicipalResultStatus } from "./municipal-result-status";

describe("getMunicipalResultStatus", () => {
  it("登録された議決結果を反映する", () => {
    for (const result of ["原案可決", "認定", "同意する"])
      expect(getMunicipalResultStatus(result, "introduced")).toBe("enacted");
    for (const result of ["否決", "不認定", "不同意"])
      expect(getMunicipalResultStatus(result, "introduced")).toBe("rejected");
  });
  it("未登録や継続審査では議決済みと決めつけない", () => {
    expect(getMunicipalResultStatus(null, "introduced")).toBe("introduced");
    expect(getMunicipalResultStatus("継続審査", "in_originating_house")).toBe(
      "in_originating_house"
    );
  });
});
