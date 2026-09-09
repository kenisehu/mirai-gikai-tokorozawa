import { describe, expect, it } from "vitest";
import { getArchiveBills } from "./archive-bills";

describe("getArchiveBills", () => {
  it("6月40件・2月42件がすべて個別資料と解説を持つ", () => {
    for (const [slug, count] of [
      ["2026-06", 40],
      ["2026-02", 42],
    ] as const) {
      const bills = getArchiveBills(slug);
      expect(bills).toHaveLength(count);
      expect(new Set(bills.map((bill) => bill.id)).size).toBe(count);
      for (const bill of bills) {
        expect(bill.pdfUrl).toMatch(
          /^https:\/\/www\.city\.tokorozawa\.saitama\.jp\/.+\.pdf$/
        );
        expect(bill.resultUrl).toContain(".pdf#page=");
        expect(bill.explanation.length).toBeGreaterThan(70);
        expect(bill.committee).not.toBe("");
        expect(bill.result).not.toBe("");
      }
    }
  });
  it("同名の否決案と成立案を区別する", () => {
    const bills = getArchiveBills("2026-02");
    for (const [rejected, passed] of [
      ["bill-7", "bill-42"],
      ["bill-16", "bill-43"],
    ]) {
      const original = bills.find((bill) => bill.id === rejected);
      const revised = bills.find((bill) => bill.id === passed);
      expect(original?.title).toBe(revised?.title);
      expect(original?.result).toBe("否決");
      expect(revised?.result).toBe("原案可決");
      expect(original?.pdfUrl).not.toBe(revised?.pdfUrl);
    }
  });
  it("委員会欄が空欄の契約や人事を推測で補わない", () => {
    expect(
      getArchiveBills("2026-06").find((bill) => bill.id === "bill-61")
        ?.committee
    ).toContain("記載なし");
    expect(
      getArchiveBills("2026-06").find((bill) => bill.id === "bill-65")?.result
    ).toBe("同意する");
  });
  it("未知の会議には別会議のデータを出さない", () => {
    expect(getArchiveBills("2025-06")).toEqual([]);
  });
});
