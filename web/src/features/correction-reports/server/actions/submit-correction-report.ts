"use server";

import { correctionReportSchema } from "../../shared/utils/correction-report-validation";
import { createCorrectionReport } from "../repositories/correction-report-repository";
import { allowCorrectionReport } from "../services/correction-report-rate-limit";

export type CorrectionReportState = {
  status: "idle" | "success" | "error";
  message?: string;
};

export async function submitCorrectionReport(
  _state: CorrectionReportState,
  formData: FormData
): Promise<CorrectionReportState> {
  const parsed = correctionReportSchema.safeParse({
    billId: formData.get("billId"),
    billName: formData.get("billName"),
    pageUrl: formData.get("pageUrl"),
    reportType: formData.get("reportType"),
    location: formData.get("location"),
    description: formData.get("description"),
    sourceUrl: formData.get("sourceUrl"),
    website: formData.get("website"),
  });

  if (!parsed.success) {
    return {
      status: "error",
      message: parsed.error.issues[0]?.message ?? "入力内容を確認してください",
    };
  }

  try {
    if (!(await allowCorrectionReport())) {
      return {
        status: "error",
        message:
          "送信が集中しているか、受付を一時的に利用できません。同じ回線からは1分に1回・1時間に5回までです。時間をおいてお試しください。",
      };
    }
    await createCorrectionReport(parsed.data);
    return { status: "success" };
  } catch {
    return {
      status: "error",
      message: "送信できませんでした。時間をおいてもう一度お試しください。",
    };
  }
}
