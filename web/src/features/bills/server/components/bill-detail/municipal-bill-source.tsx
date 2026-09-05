import { ExternalLink, FileText, Landmark } from "lucide-react";
import type { MunicipalBillMetadata } from "../../../shared/types";

interface MunicipalBillSourceProps {
  metadata: MunicipalBillMetadata;
}

const formatRetrievedDate = (value: string) =>
  new Intl.DateTimeFormat("ja-JP", {
    year: "numeric",
    month: "long",
    day: "numeric",
    timeZone: "Asia/Tokyo",
  }).format(new Date(value));

export function MunicipalBillSource({ metadata }: MunicipalBillSourceProps) {
  return (
    <section className="my-8 rounded-lg border bg-white p-6">
      <div className="mb-4 flex items-center gap-2">
        <Landmark className="size-5 text-primary" aria-hidden="true" />
        <h2 className="text-xl font-bold">所沢市議会の公式情報</h2>
      </div>
      <dl className="grid gap-3 text-sm sm:grid-cols-[8rem_1fr]">
        <dt className="font-bold">議案番号</dt>
        <dd>{metadata.bill_number}</dd>
        <dt className="font-bold">会議</dt>
        <dd>{metadata.meeting_name}</dd>
        {metadata.responsible_department && (
          <>
            <dt className="font-bold">担当課</dt>
            <dd>{metadata.responsible_department}</dd>
          </>
        )}
      </dl>
      <div className="mt-5 flex flex-wrap gap-3">
        <a
          href={metadata.bill_document_url ?? metadata.official_page_url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-bold text-white hover:opacity-80"
        >
          <FileText className="size-4" aria-hidden="true" />
          公式議案PDF
          <ExternalLink className="size-3" aria-hidden="true" />
        </a>
        {metadata.supplementary_document_url && (
          <a
            href={metadata.supplementary_document_url}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 rounded-md border border-primary px-4 py-2 text-sm font-bold text-primary hover:bg-white-100"
          >
            関連資料
            <ExternalLink className="size-3" aria-hidden="true" />
          </a>
        )}
        <a
          href={metadata.official_page_url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-2 py-2 text-sm font-bold text-primary-accent hover:opacity-80"
        >
          所沢市公式ページ
          <ExternalLink className="size-3" aria-hidden="true" />
        </a>
      </div>
      <p className="mt-4 text-xs text-mirai-text-note">
        出典確認日：{formatRetrievedDate(metadata.source_retrieved_at)}
      </p>
    </section>
  );
}
