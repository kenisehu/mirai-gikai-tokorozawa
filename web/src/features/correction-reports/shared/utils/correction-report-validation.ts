import { z } from "zod";

const optionalHttpsUrl = z
  .string()
  .trim()
  .max(500, "URLは500文字以内で入力してください")
  .refine(
    (value) =>
      !value ||
      (z.string().url().safeParse(value).success &&
        value.startsWith("https://")),
    {
      message: "URLは https:// から始まるものを入力してください",
    }
  );

export const correctionReportSchema = z.object({
  billId: z.union([z.literal(""), z.string().uuid()]),
  billName: z.string().trim().min(1).max(300),
  pageUrl: z
    .string()
    .url()
    .max(500)
    .refine((value) => value.startsWith("https://")),
  reportType: z.enum(["factual_error", "unclear", "broken_link", "other"]),
  location: z
    .string()
    .trim()
    .max(300, "該当箇所は300文字以内で入力してください"),
  description: z
    .string()
    .trim()
    .min(10, "内容は10文字以上で入力してください")
    .max(2000, "内容は2000文字以内で入力してください"),
  sourceUrl: optionalHttpsUrl,
  website: z.string().max(0),
});

export type CorrectionReportInput = z.infer<typeof correctionReportSchema>;
