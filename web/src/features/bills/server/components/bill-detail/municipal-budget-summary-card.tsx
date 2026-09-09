import { ArrowUpRight, CirclePlus, Landmark } from "lucide-react";
import type { Route } from "next";
import Link from "next/link";
import { getMunicipalBudgetSummary } from "../../../shared/utils/municipal-budget-summary";

export function MunicipalBudgetSummaryCard({
  billName,
  sourceUrl,
}: {
  billName: string;
  sourceUrl: string;
}) {
  const summary = getMunicipalBudgetSummary(billName);
  if (!summary) return null;

  return (
    <section className="my-8 overflow-hidden rounded-2xl border bg-white shadow-sm">
      <div className="flex items-center gap-2 border-b bg-muted/30 px-5 py-3 text-sm font-bold">
        <Landmark className="size-4 text-primary" />
        予算のポイント
      </div>
      <div className="grid gap-5 p-5 sm:grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] sm:p-6">
        <div className="rounded-xl bg-primary/5 p-5 text-center">
          <span className="inline-flex items-center gap-1 rounded-full bg-primary px-3 py-1 text-xs font-bold text-primary-foreground">
            <CirclePlus className="size-3.5" />
            {summary.changeLabel}
          </span>
          <p className="mt-3 text-3xl font-black tracking-tight">
            {summary.amountLabel}
          </p>
        </div>
        <div className="flex flex-col justify-center">
          <p className="text-sm text-muted-foreground">主な対象</p>
          <p className="mt-1 text-lg font-bold">{summary.purpose}</p>
          <p className="mt-3 text-xs leading-5 text-muted-foreground">
            {summary.note}
          </p>
          <Link
            href={sourceUrl as Route}
            target="_blank"
            rel="noreferrer"
            className="mt-3 inline-flex items-center gap-1 text-sm font-bold text-primary underline underline-offset-4"
          >
            所沢市の元資料で確認する
            <ArrowUpRight className="size-4" />
          </Link>
        </div>
      </div>
    </section>
  );
}
