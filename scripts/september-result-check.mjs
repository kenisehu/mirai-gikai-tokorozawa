// Inspect explicit rendered fields, never words from the explanatory prose.
export function inspectSeptemberBill(html) {
  const result = html.match(/data-municipal-result="([^"]*)"/)?.[1];
  const label = html.match(/data-bill-status-label="([^"]*)"/)?.[1];
  const voteOnSeptember14 = /<li\b[^>]*data-event-type="vote"[^>]*data-event-date="2026-09-14"/.test(html);
  let group = null;
  const errors = [];
  if (result === "決算特別委員会に付託（最終結果未確認）") {
    group = "accounts";
    if (label !== "決算審査中") errors.push("account badge mismatch");
    if (voteOnSeptember14) errors.push("account incorrectly has a September 14 vote");
  } else if (result === "回答する") {
    group = "answered";
    if (label !== "回答する") errors.push("consultation badge mismatch");
    if (!voteOnSeptember14) errors.push("answer event missing");
  } else if (result === "可決" || result === "原案可決") {
    group = "approved";
    if (label !== "可決") errors.push("approval badge mismatch");
    if (!voteOnSeptember14) errors.push("approval event missing");
  } else errors.push("result field missing or unexpected");
  return { group, errors };
}
