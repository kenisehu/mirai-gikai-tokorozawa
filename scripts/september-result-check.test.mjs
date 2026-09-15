import assert from "node:assert/strict";
import { test } from "node:test";
import { inspectSeptemberBill } from "./september-result-check.mjs";

const vote = '<li data-event-type="vote" data-event-date="2026-09-14">';
const markup = (result, label, event = "") => `<dd data-municipal-result="${result}">${result}</dd><span data-bill-status-label="${label}">${label}</span>${event}`;

test("explanatory words alone cannot pass the release check", () => {
  assert.equal(inspectSeptemberBill("可決したことと受付開始は別です。回答する。").group, null);
});
test("consultation with an incorrect approval badge fails", () => {
  assert.deepEqual(inspectSeptemberBill(markup("回答する", "可決", vote)).errors, ["consultation badge mismatch"]);
});
test("decisions require their dated event", () => {
  assert.ok(inspectSeptemberBill(markup("原案可決", "可決")).errors.includes("approval event missing"));
  assert.equal(inspectSeptemberBill(markup("回答する", "回答する", vote)).errors.length, 0);
  assert.equal(inspectSeptemberBill(markup("原案可決", "可決", vote)).errors.length, 0);
});
test("accounts remain pending, without a vote", () => {
  const html = markup("決算特別委員会に付託（最終結果未確認）", "決算審査中");
  assert.deepEqual(inspectSeptemberBill(html), { group: "accounts", errors: [] });
  assert.ok(inspectSeptemberBill(html + vote).errors.length > 0);
});
