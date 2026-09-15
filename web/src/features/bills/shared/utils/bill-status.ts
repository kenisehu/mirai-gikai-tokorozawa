import type { BillStatusEnum } from "../types";

/** カード用の簡略化されたステータスラベルを取得 */
export function getCardStatusLabel(
  status: BillStatusEnum,
  statusNote?: string | null
): string {
  if (status === "enacted" && statusNote?.includes("回答する"))
    return "回答する";
  if (
    status === "in_originating_house" &&
    statusNote?.includes("決算特別委員会")
  )
    return "決算審査中";
  switch (status) {
    case "introduced":
    case "in_originating_house":
    case "in_receiving_house":
      return "市議会で審議中";
    case "enacted":
      return "可決";
    case "rejected":
      return "否決";
    default:
      return "議案提出前";
  }
}

/** ステータスに対応するBadgeのvariantを取得 */
export function getStatusVariant(
  status: BillStatusEnum
): "light" | "default" | "dark" | "muted" {
  switch (status) {
    case "introduced":
    case "in_originating_house":
    case "in_receiving_house":
      return "light";
    case "enacted":
      return "default";
    case "rejected":
      return "dark";
    default:
      return "muted";
  }
}
