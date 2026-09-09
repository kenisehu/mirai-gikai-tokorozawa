// Mechanical extraction of official titles and document links.
// Editorial explanations and decisions are reviewed separately.
import { writeFile } from "node:fs/promises";
const base = "https://www.city.tokorozawa.saitama.jp";
const text = (html) => html.replace(/<[^>]*>/g, "").replace(/&nbsp;|&#160;/g, " ").replace(/&amp;/g, "&").replace(/\s+/g, " ").trim();
const sessions = {};
for (const [slug, page, count] of [
  ["2026-06", "/shiseijoho/shichougian/reiwa8nendai4kai.html", 40],
  ["2026-02", "/shiseijoho/shichougian/reiwa8nendai2kai.html", 42],
]) {
  const url = base + page;
  const response = await fetch(url);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const html = await response.text();
  const rows = [...html.matchAll(/<tr\b[^>]*>([\s\S]*?)<\/tr>/gi)];
  const bills = [];
  for (const [, row] of rows) {
    const cells = [...row.matchAll(/<t[dh]\b[^>]*>([\s\S]*?)<\/t[dh]>/gi)].map((match) => match[1]);
    const number = text(cells[0] ?? "");
    if (!/^(議案|諮問)第\d+号$/.test(number)) continue;
    const links = [...row.matchAll(/href=["']([^"']+\.pdf)["']/gi)].map((match) => new URL(match[1], url).href);
    if (!links.length) throw new Error(`Missing PDF: ${number}`);
    bills.push({
      id: `${number.startsWith("諮問") ? "inquiry" : "bill"}-${number.match(/\d+/)[0]}`,
      number,
      title: text(cells[1]),
      pdfUrl: links[0],
      supportingPdfUrl: links[1] ?? null,
    });
  }
  if (bills.length !== count) throw new Error(`${slug}: expected ${count}, got ${bills.length}`);
  sessions[slug] = bills;
}
await writeFile(new URL("../web/src/features/session-archive/shared/official-bills.json", import.meta.url), JSON.stringify(sessions, null, 2) + "\n");
console.log("Official archive extracted: June 40, February 42");
