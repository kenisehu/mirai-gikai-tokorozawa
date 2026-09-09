"use server";
import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireAdmin } from "@/features/auth/server/lib/auth-server";
import { routes } from "@/lib/routes";
import { correctionStatusSchema } from "../../shared/utils/correction-status";
import { setCorrectionReportStatus } from "../repositories/correction-reports-repository";

export async function updateCorrectionStatus(formData: FormData) {
  await requireAdmin();
  const id = z.string().uuid().parse(formData.get("id"));
  const status = correctionStatusSchema.parse(formData.get("status"));
  const previousStatus = correctionStatusSchema.parse(
    formData.get("previousStatus")
  );
  await setCorrectionReportStatus(id, status, previousStatus);
  revalidatePath(routes.correctionReports());
}
