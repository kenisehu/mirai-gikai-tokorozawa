import { describe, expect, it } from "vitest";
import { correctionReportSchema } from "./correction-report-validation";

const validInput = {
  billId: "00000000-0000-4000-8000-000000000000",
  billName: "議案第85号",
  pageUrl: "https://example.com/bills/1",
  reportType: "factual_error",
  location: "概要の2段落目",
  description: "記載されている金額が公式資料と異なります。",
  sourceUrl: "https://example.com/source.pdf",
  website: "",
};

describe("correctionReportSchema", () => {
  it("httpsで始まっても壊れたURLは拒否する", () => {
    expect(
      correctionReportSchema.safeParse({ ...validInput, sourceUrl: "https://" })
        .success
    ).toBe(false);
  });
  it("個人情報なしの有効な報告を受け付ける", () => {
    expect(correctionReportSchema.safeParse(validInput).success).toBe(true);
  });

  it("短すぎる内容とhttps以外の根拠URLを拒否する", () => {
    const result = correctionReportSchema.safeParse({
      ...validInput,
      description: "誤り",
      sourceUrl: "http://example.com",
    });
    expect(result.success).toBe(false);
  });

  it("迷惑送信用の隠し項目に値があれば拒否する", () => {
    expect(
      correctionReportSchema.safeParse({ ...validInput, website: "spam" })
        .success
    ).toBe(false);
  });
});
