import { readFile, mkdir, writeFile } from "node:fs/promises";
const sessions = JSON.parse(await readFile(new URL("../web/src/features/session-archive/shared/official-bills.json", import.meta.url), "utf8"));
await mkdir(new URL("../tmp/pdfs/archive/", import.meta.url), { recursive: true });
const queue = Object.entries(sessions).flatMap(([slug, bills]) => bills.map((bill) => ({ slug, ...bill })));
await Promise.all(Array.from({ length: 4 }, async () => {
  while (queue.length) {
    const bill = queue.shift();
    const response = await fetch(bill.pdfUrl);
    if (!response.ok) throw new Error(`${bill.pdfUrl}: ${response.status}`);
    await writeFile(new URL(`../tmp/pdfs/archive/${bill.slug}-${bill.id}.pdf`, import.meta.url), Buffer.from(await response.arrayBuffer()));
  }
}));
console.log("82 official PDFs downloaded");
