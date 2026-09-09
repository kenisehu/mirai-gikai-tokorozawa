import type { BillStatusEnum } from "../types";

export function getMunicipalResultStatus(
  result: string | null | undefined,
  fallback: BillStatusEnum
): BillStatusEnum {
  if (!result) return fallback;
  if (/否決|不認定|不同意/.test(result)) return "rejected";
  if (/可決|認定|同意/.test(result)) return "enacted";
  return fallback;
}
