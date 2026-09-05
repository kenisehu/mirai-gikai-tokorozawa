import type { Database } from "@mirai-gikai/supabase";
import type { TokorozawaOfficialBill } from "./parse-official-bills.js";

type BillInsert = Database["public"]["Tables"]["bills"]["Insert"];
type MetadataInsert =
  Database["public"]["Tables"]["municipal_bill_metadata"]["Insert"];

export type TokorozawaDatabaseRecords = {
  bill: BillInsert;
  metadata: Omit<MetadataInsert, "bill_id">;
};

export const toTokorozawaDatabaseRecords = (
  source: TokorozawaOfficialBill,
  sourceRetrievedAt: string,
): TokorozawaDatabaseRecords => ({
  bill: {
    name: source.title,
    // 既存スキーマは国会の発議院を必須としている。地方議会対応UIへの移行までは
    // 市長提出をメタデータで正しく識別し、互換値としてHRを保持する。
    originating_house: "HR",
    status: "introduced",
    status_note: `${source.billNumber} 所沢市議会へ市長提出`,
    submitted_date: `${source.sourcePublishedAt}T00:00:00+09:00`,
    publish_status: "draft",
    is_featured: false,
    is_review_completed: false,
  },
  metadata: {
    municipality_name: source.municipalityName,
    meeting_name: source.meetingName,
    bill_number: source.billNumber,
    submitting_body: source.submittingBody,
    responsible_department: source.responsibleDepartment,
    official_page_url: source.officialPageUrl,
    bill_document_url: source.billDocumentUrl,
    supplementary_document_url: source.supplementaryDocumentUrl,
    source_published_at: `${source.sourcePublishedAt}T00:00:00+09:00`,
    source_retrieved_at: sourceRetrievedAt,
  },
});
