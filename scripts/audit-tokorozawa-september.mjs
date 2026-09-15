// Read-only release check for the 2026-09-15 snapshot; no credentials or writes.
// Run: node scripts/audit-tokorozawa-september.mjs [public base URL]
import { inspectSeptemberBill } from "./september-result-check.mjs";
const base = new URL(process.argv[2] ?? "https://mirai-gikai-tokorozawa.vercel.app");
const errors = [];
const pages = new Map();

async function read(path) {
  const url = new URL(path, base);
  if (url.origin !== base.origin) throw new Error("Only same-origin pages are audited");
  const response = await fetch(url, { signal: AbortSignal.timeout(30000) });
  if (!response.ok) throw new Error(`${path}: HTTP ${response.status}`);
  return response.text();
}

function visibleText(html) {
  return html.replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<style\b[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<[^>]*>/g, " ").replace(/\s+/g, " ");
}

try {
  const sitemap = await read("/sitemap.xml");
  const bills = [...new Set([...sitemap.matchAll(/<loc>([^<]+)<\/loc>/g)]
    .map((match) => new URL(match[1]).pathname)
    .filter((path) => /^\/bills\/[a-f0-9-]{36}$/.test(path)))];
  if (bills.length !== 41) errors.push(`Expected 41 bills for this snapshot, got ${bills.length}. Review scope before updating expectations.`);
  const paths = ["/", "/bills", "/general-questions", "/sessions", "/guide", "/updates", "/corrections", ...bills];
  // Bounded concurrency avoids a large burst against production.
  for (let i = 0; i < paths.length; i += 3) {
    await Promise.all(paths.slice(i, i + 3).map(async (path) => {
      try {
        const html = await read(path);
        const text = visibleText(html);
        pages.set(path, { html, text });
        if (text.includes("9月14日の採決予定") || text.includes("市長提出議案の結果は未公表")) {
          errors.push(`${path}: stale result wording`);
        }
        if (text.includes("Application error") || text.includes("ページが見つかりません")) errors.push(`${path}: error page`);
      } catch (error) { errors.push(error.message); }
    }));
  }
  const counts = { approved: 0, answered: 0, accounts: 0 };
  for (const path of bills) {
    const page = pages.get(path);
    if (!page) continue;
    if (!page.html.includes("city.tokorozawa.saitama.jp")) errors.push(`${path}: official source missing`);
    if (!page.html.includes("/corrections?")) errors.push(`${path}: correction link missing`);
    const checked = inspectSeptemberBill(page.html);
    if (checked.group) counts[checked.group]++;
    errors.push(...checked.errors.map((message) => `${path}: ${message}`));
  }
  if (counts.approved !== 29 || counts.answered !== 2 || counts.accounts !== 10) errors.push(`Result totals mismatch: ${JSON.stringify(counts)}`);
  if (!pages.get("/")?.text.includes("今回の議会、ここから読む")) errors.push("Home: reading entry points missing");
  if (![...pages.values()].some((p) => p.text.includes("全額が新しい介護サービスに使われるわけではありません"))) errors.push("Budget explanation is not deployed");
  console.log(JSON.stringify({ snapshot: "2026-09-15", checkedAt: new Date().toISOString(), origin: base.origin, checkedPages: pages.size, counts, errors }, null, 2));
  process.exitCode = errors.length ? 1 : 0;
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
