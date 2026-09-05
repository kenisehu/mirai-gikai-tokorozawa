import { createAdminClient } from "../../shared/helper.js";
import { parseTokorozawaOfficialBills } from "./parse-official-bills.js";
import { toTokorozawaDatabaseRecords } from "./to-database-records.js";

const DEFAULT_URL =
  "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html";

const officialPageUrl = process.argv[2] ?? DEFAULT_URL;
const response = await fetch(officialPageUrl);
if (!response.ok) {
  throw new Error(`公式ページの取得に失敗しました: HTTP ${response.status}`);
}

const sources = parseTokorozawaOfficialBills(
  await response.text(),
  officialPageUrl,
);
const sourceRetrievedAt = new Date().toISOString();
const supabase = createAdminClient();
let created = 0;
let updated = 0;

for (const source of sources) {
  const records = toTokorozawaDatabaseRecords(source, sourceRetrievedAt);
  const { data: existing, error: lookupError } = await supabase
    .from("municipal_bill_metadata")
    .select("bill_id")
    .eq("municipality_name", records.metadata.municipality_name)
    .eq("meeting_name", records.metadata.meeting_name)
    .eq("bill_number", records.metadata.bill_number)
    .maybeSingle();
  if (lookupError) {
    throw new Error(`${source.billNumber}の照合に失敗: ${lookupError.message}`);
  }

  if (existing) {
    const { error: billError } = await supabase
      .from("bills")
      .update({
        name: records.bill.name,
        status_note: records.bill.status_note,
        submitted_date: records.bill.submitted_date,
      })
      .eq("id", existing.bill_id);
    if (billError) {
      throw new Error(`${source.billNumber}の更新に失敗: ${billError.message}`);
    }
    const { error: metadataError } = await supabase
      .from("municipal_bill_metadata")
      .update(records.metadata)
      .eq("bill_id", existing.bill_id);
    if (metadataError) {
      throw new Error(
        `${source.billNumber}の出典更新に失敗: ${metadataError.message}`,
      );
    }
    updated += 1;
    continue;
  }

  const { data: insertedBill, error: billError } = await supabase
    .from("bills")
    .insert(records.bill)
    .select("id")
    .single();
  if (billError || !insertedBill) {
    throw new Error(`${source.billNumber}の登録に失敗: ${billError?.message}`);
  }

  const { error: metadataError } = await supabase
    .from("municipal_bill_metadata")
    .insert({ ...records.metadata, bill_id: insertedBill.id });
  if (metadataError) {
    await supabase.from("bills").delete().eq("id", insertedBill.id);
    throw new Error(
      `${source.billNumber}の出典登録に失敗: ${metadataError.message}`,
    );
  }
  created += 1;
}

console.log(
  `所沢市の議案${sources.length}件を処理しました（新規${created}件、更新${updated}件）`,
);
