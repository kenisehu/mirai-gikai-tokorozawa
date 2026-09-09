import "server-only";
import { createAdminClient } from "@mirai-gikai/supabase";
import { requireAdmin } from "@/features/auth/server/lib/auth-server";

export async function findCorrectionReports(status: string) {
  await requireAdmin();
  const { data, error } = await createAdminClient()
    .from("correction_reports")
    .select("*")
    .eq("status", status)
    .order("created_at", { ascending: false })
    .limit(100);
  if (error) throw new Error("訂正報告を取得できませんでした");
  return data;
}

export async function setCorrectionReportStatus(
  id: string,
  status: string,
  previousStatus: string
) {
  await requireAdmin();
  const { data, error } = await createAdminClient()
    .from("correction_reports")
    .update({ status })
    .eq("id", id)
    .eq("status", previousStatus)
    .select("id")
    .single();
  if (error || !data)
    throw new Error(
      "報告が更新された可能性があります。画面を再読込してください"
    );
}
