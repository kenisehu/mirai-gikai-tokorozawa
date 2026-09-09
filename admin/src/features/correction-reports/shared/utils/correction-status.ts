import { z } from "zod";

export const correctionStatusSchema = z.enum([
  "new",
  "reviewing",
  "resolved",
  "dismissed",
]);
export const correctionStatusLabels = {
  new: "未対応",
  reviewing: "確認中",
  resolved: "対応済み",
  dismissed: "修正不要",
} as const;
