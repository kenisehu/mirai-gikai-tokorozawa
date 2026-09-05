import { describe, expect, it } from "vitest";
import { parseTokorozawaOfficialBills } from "./parse-official-bills.js";

const page = (rows: string) => `
  <div class="update">更新日：2026年9月1日</div>
  <table><caption>令和8年第5回(9月)定例会議市長提出議案</caption>
    <tr><th>議案番号</th><th>件名</th><th>公開資料</th><th>所管</th></tr>
    ${rows}
  </table>`;

describe("parseTokorozawaOfficialBills", () => {
  it("相対URLを絶対URLにし、rowspanの資料を後続議案にも引き継ぐ", () => {
    const html = page(`
      <tr><td>議案第85号</td><td>一般会計補正予算</td>
        <td><a href="files/85.pdf">議案(PDF:1KB)</a></td>
        <td rowspan="2"><a href="files/material.pdf">資料(PDF:2KB)</a></td>
        <td>財政課</td></tr>
      <tr><td>議案第86号</td><td>特別会計補正予算</td>
        <td><a href="files/86.pdf">議案(PDF:1KB)</a></td><td>財政課</td></tr>`);

    const bills = parseTokorozawaOfficialBills(
      html,
      "https://example.jp/council/page.html",
    );

    expect(bills).toHaveLength(2);
    expect(bills[0]).toMatchObject({
      billNumber: "議案第85号",
      billDocumentUrl: "https://example.jp/council/files/85.pdf",
      supplementaryDocumentUrl:
        "https://example.jp/council/files/material.pdf",
      sourcePublishedAt: "2026-09-01",
    });
    expect(bills[1]?.supplementaryDocumentUrl).toBe(
      "https://example.jp/council/files/material.pdf",
    );
  });

  it("表の構造が変わり必須資料がない場合は誤登録せず停止する", () => {
    const html = page(
      "<tr><td>議案第85号</td><td>件名</td><td>財政課</td></tr>",
    );
    expect(() =>
      parseTokorozawaOfficialBills(html, "https://example.jp/page.html"),
    ).toThrow("議案第85号の資料または所管を取得できませんでした");
  });
});
