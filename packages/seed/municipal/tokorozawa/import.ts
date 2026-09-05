import { writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { parseTokorozawaOfficialBills } from "./parse-official-bills.js";

const DEFAULT_URL =
  "https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html";

const officialPageUrl = process.argv[2] ?? DEFAULT_URL;
const outputPath = resolve(process.argv[3] ?? "tokorozawa-official-bills.json");
const response = await fetch(officialPageUrl);
if (!response.ok) {
  throw new Error(`公式ページの取得に失敗しました: HTTP ${response.status}`);
}

const bills = parseTokorozawaOfficialBills(
  await response.text(),
  officialPageUrl,
);
const sourceRetrievedAt = new Date().toISOString();
await writeFile(
  outputPath,
  `${JSON.stringify(
    bills.map((bill) => ({ ...bill, sourceRetrievedAt })),
    null,
    2,
  )}\n`,
  "utf8",
);
console.log(`${bills.length}件を ${outputPath} に保存しました`);
