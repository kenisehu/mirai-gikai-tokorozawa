import "server-only";

import { createAdminClient } from "@mirai-gikai/supabase";
import type { CorrectionReportInput } from "../../shared/utils/correction-report-validation";

export async function createCorrectionReport(input: CorrectionReportInput) {
  const supabase = createAdminClient();
  const { error } = await supabase.from("correction_reports").insert({
    bill_id: input.billId || null,
    bill_name: input.billName,
    page_url: input.pageUrl,
    report_type: input.reportType,
    location: input.location || null,
    description: input.description,
    source_url: input.sourceUrl || null,
  });

  if (error)
    throw new Error(`Failed to create correction report: ${error.message}`);
}
