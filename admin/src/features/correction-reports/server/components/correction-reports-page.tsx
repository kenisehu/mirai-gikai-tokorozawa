import "server-only";
import type { Route } from "next";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { routes } from "@/lib/routes";
import {
  correctionStatusLabels,
  correctionStatusSchema,
} from "../../shared/utils/correction-status";
import { updateCorrectionStatus } from "../actions/update-correction-status";
import { findCorrectionReports } from "../repositories/correction-reports-repository";

export async function CorrectionReportsPage({ status }: { status?: string }) {
  const selected = correctionStatusSchema.safeParse(status);
  const currentStatus = selected.success ? selected.data : "new";
  const reports = await findCorrectionReports(currentStatus);
  return (
    <main className="container mx-auto space-y-6 py-8">
      <h1 className="text-2xl font-bold">訂正・改善の報告</h1>
      <p>
        報告は非公開です。根拠を確認して必要な修正を行った後、対応状況を更新してください。
      </p>
      <nav className="flex flex-wrap gap-4" aria-label="対応状況">
        {Object.entries(correctionStatusLabels).map(([value, label]) => (
          <Link
            key={value}
            href={`${routes.correctionReports()}?status=${value}` as Route}
            aria-current={currentStatus === value ? "page" : undefined}
            className="underline"
          >
            {label}
          </Link>
        ))}
      </nav>
      <p>{correctionStatusLabels[currentStatus]}：最新100件まで表示</p>
      {reports.length === 0 && <p>該当する報告はありません。</p>}
      {reports.map((report) => (
        <article key={report.id} className="space-y-3 rounded-lg border p-5">
          <h2 className="text-lg font-bold">{report.bill_name}</h2>
          <p className="text-sm">
            {new Date(report.created_at).toLocaleString("ja-JP", {
              timeZone: "Asia/Tokyo",
            })}
            （日本時間）・{report.report_type}
          </p>
          <p>該当箇所：{report.location || "指定なし"}</p>
          <p className="whitespace-pre-wrap break-words">
            {report.description}
          </p>
          <p className="break-all">対象URL：{report.page_url}</p>
          {report.source_url && (
            <p className="break-all">
              報告者の根拠URL（未検証）：{report.source_url}
            </p>
          )}
          <form
            action={updateCorrectionStatus}
            className="flex items-center gap-3"
          >
            <input type="hidden" name="id" value={report.id} />
            <input type="hidden" name="previousStatus" value={report.status} />
            <label htmlFor={report.id}>対応状況</label>
            <select
              id={report.id}
              name="status"
              defaultValue={report.status}
              className="rounded border p-2"
            >
              {Object.entries(correctionStatusLabels).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
            <Button type="submit">保存</Button>
          </form>
        </article>
      ))}
    </main>
  );
}
