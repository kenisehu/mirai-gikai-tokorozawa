import { ARCHIVE_EXPLANATIONS } from "../archive-explanations";
import officialBills from "../official-bills.json";
import officialResults from "../official-results.json";

const resultsUrls: Record<string, string> = {
  "2026-06":
    "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai4/R8_dai4kai_kekka.files/shityokekka_R8.6.19.pdf",
  "2026-02":
    "https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai2/R8_dai2kai_kekka.files/shityokekka_R8.3.24_2.pdf",
};

export function getArchiveBills(slug: string) {
  if (slug !== "2026-06" && slug !== "2026-02") return [];
  const results: Record<
    string,
    { committee: string; result: string; resultPage: number }
  > = officialResults[slug];
  return officialBills[slug].map((bill) => {
    const decision = results[bill.id];
    const explanation = ARCHIVE_EXPLANATIONS[slug]?.[bill.id];
    if (!decision || !explanation)
      throw new Error("Archive verification incomplete");
    const committee = ["＿", "-"].includes(decision.committee)
      ? "付託委員会の記載なし（公式結果表は「－」）"
      : `${decision.committee}常任委員会`;
    return {
      ...bill,
      headline: explanation[0],
      explanation: explanation[1],
      committee,
      result: decision.result,
      resultUrl: `${resultsUrls[slug]}#page=${decision.resultPage}`,
    };
  });
}
