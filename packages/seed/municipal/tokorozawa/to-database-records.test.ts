import { describe, expect, it } from "vitest";
import type { TokorozawaOfficialBill } from "./parse-official-bills.js";
import { toTokorozawaDatabaseRecords } from "./to-database-records.js";

const source: TokorozawaOfficialBill = {
  municipalityName: "所沢市",
  meetingName: "令和8年第5回(9月)定例会議市長提出議案",
  billNumber: "議案第85号",
  title: "令和8年度所沢市一般会計補正予算（第2号）",
  submittingBody: "市長",
  responsibleDepartment: "財政課",
  officialPageUrl: "https://example.jp/page.html",
  billDocumentUrl: "https://example.jp/bill.pdf",
  supplementaryDocumentUrl: "https://example.jp/material.pdf",
  sourcePublishedAt: "2026-09-01",
};

describe("toTokorozawaDatabaseRecords", () => {
  it("新規議案を非公開の下書きとして登録する", () => {
    const records = toTokorozawaDatabaseRecords(
      source,
      "2026-09-05T10:00:00.000Z",
    );

    expect(records.bill).toMatchObject({
      name: source.title,
      publish_status: "draft",
      status: "introduced",
      status_note: "議案第85号 所沢市議会へ市長提出",
      submitted_date: "2026-09-01T00:00:00+09:00",
    });
    expect(records.metadata).toMatchObject({
      municipality_name: "所沢市",
      bill_number: "議案第85号",
      responsible_department: "財政課",
      source_retrieved_at: "2026-09-05T10:00:00.000Z",
    });
  });
});
