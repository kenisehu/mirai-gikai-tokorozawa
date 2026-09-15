import type { BillStatusEnum } from "../types";

export function getMunicipalResultStatus(
  result: string | null | undefined,
  fallback: BillStatusEnum
): BillStatusEnum {
  if (!result) return fallback;
  // 「認定予定」「可決か未確認」など、結果以外の文章を議決済みと扱わない。
  const normalized = result.trim();
  if (/^(否決|不認定|不同意)(する)?$/.test(normalized)) return "rejected";
  if (/^(原案可決|修正可決|可決|認定|同意|回答)(する)?$/.test(normalized))
    return "enacted";
  return fallback;
}
