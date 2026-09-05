import type { BillStatusEnum } from "../../../shared/types";

interface MunicipalBillStatusProps {
  status: BillStatusEnum;
  statusNote?: string | null;
}

const statusLabels: Record<BillStatusEnum, string> = {
  preparing: "公開準備中",
  introduced: "市長提出済み",
  in_originating_house: "市議会で審議中",
  in_receiving_house: "市議会で審議中",
  enacted: "可決・成立",
  rejected: "否決",
};

export function MunicipalBillStatus({
  status,
  statusNote,
}: MunicipalBillStatusProps) {
  return (
    <section>
      <h2 className="mb-4 text-[22px] font-bold">👉 審議のステータス</h2>
      <div className="rounded-lg border bg-white p-6">
        <p className="rounded-lg bg-mirai-gradient px-4 py-3.5 text-center text-base font-medium text-black">
          {statusNote || statusLabels[status]}
        </p>
        <div className="mt-6 grid grid-cols-3 gap-2 text-center text-sm">
          <span className="font-bold text-primary">市長提出</span>
          <span
            className={
              status === "introduced" || status === "preparing"
                ? "text-gray-300"
                : "font-bold text-primary"
            }
          >
            市議会審議
          </span>
          <span
            className={
              status === "enacted" || status === "rejected"
                ? "font-bold text-primary"
                : "text-gray-300"
            }
          >
            議決
          </span>
        </div>
      </div>
    </section>
  );
}
