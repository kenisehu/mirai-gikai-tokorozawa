import type { Route } from "next";
import Link from "next/link";
import { routes } from "@/lib/routes";
import { BillCard } from "../../client/components/bill-list/bill-card";
import { CompactBillCard } from "../../client/components/bill-list/compact-bill-card";
import type { BillsByTag } from "../../shared/types";

interface BillsByTagSectionProps {
  billsByTag: BillsByTag[];
}

const VISIBLE_BILLS_PER_TAG = 3;

export function BillsByTagSection({ billsByTag }: BillsByTagSectionProps) {
  if (billsByTag.length === 0) {
    return null;
  }

  return (
    <div className="flex flex-col gap-12">
      {billsByTag.map(({ tag, bills }) => {
        const visibleBills = bills.slice(0, VISIBLE_BILLS_PER_TAG);
        const remainingCount = bills.length - visibleBills.length;

        return (
          <section key={tag.id} className="flex flex-col gap-6">
            {/* タグヘッダー */}
            <div className="flex flex-col gap-1.5">
              <h2 className="text-[22px] font-bold text-black leading-[1.48]">
                {tag.label}
              </h2>
              {tag.description && (
                <p className="text-xs text-mirai-text-secondary">
                  {tag.description}
                </p>
              )}
            </div>

            {/*
            議案カード一覧。先頭だけフルカードで、2件目以降はコンパクトにする。
            1カテゴリに同じ大きさのカードを並べると縦に伸びて、次のカテゴリまで
            スクロールが遠くなる。
          */}
            <div className="flex flex-col gap-4">
              {visibleBills.map((bill, index) => (
                <Link key={bill.id} href={routes.billDetail(bill.id) as Route}>
                  {index === 0 ? (
                    <BillCard bill={bill} />
                  ) : (
                    <CompactBillCard bill={bill} />
                  )}
                </Link>
              ))}
            </div>
            {remainingCount > 0 && (
              <Link
                href={
                  `${routes.billsList()}?tag=${encodeURIComponent(tag.id)}` as Route
                }
                className="self-center rounded-full border border-primary px-6 py-3 text-sm font-bold text-primary-accent transition-colors hover:bg-mirai-surface-gray"
              >
                {tag.label}の議案をすべて見る（ほか{remainingCount}件）
              </Link>
            )}
          </section>
        );
      })}
    </div>
  );
}
