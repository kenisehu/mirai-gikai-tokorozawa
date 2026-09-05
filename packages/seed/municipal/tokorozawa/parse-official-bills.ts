import { JSDOM } from "jsdom";

export type TokorozawaOfficialBill = {
  municipalityName: "所沢市";
  meetingName: string;
  billNumber: string;
  title: string;
  submittingBody: "市長";
  responsibleDepartment: string;
  officialPageUrl: string;
  billDocumentUrl: string;
  supplementaryDocumentUrl: string | null;
  sourcePublishedAt: string;
};

const BILL_NUMBER_PATTERN = /^(議案|諮問|認定)第\d+号$/;

const normalizeText = (value: string | null | undefined) =>
  value?.replace(/\s+/g, " ").trim() ?? "";

const requiredText = (value: string, field: string) => {
  if (!value) throw new Error(`公式ページから${field}を取得できませんでした`);
  return value;
};

export const parseTokorozawaOfficialBills = (
  html: string,
  officialPageUrl: string,
): TokorozawaOfficialBill[] => {
  const document = new JSDOM(html, { url: officialPageUrl }).window.document;
  const table = [...document.querySelectorAll("table")].find((candidate) =>
    normalizeText(candidate.querySelector("th")?.textContent).includes("議案番号"),
  );
  if (!table) throw new Error("議案一覧の表を取得できませんでした");

  const meetingName = requiredText(
    normalizeText(table.querySelector("caption")?.textContent),
    "会議名",
  );
  const publishedMatch = normalizeText(
    document.querySelector(".update")?.textContent,
  ).match(/(\d{4})年(\d{1,2})月(\d{1,2})日/);
  if (!publishedMatch) throw new Error("公式ページから更新日を取得できませんでした");
  const [, year, month, day] = publishedMatch;
  const sourcePublishedAt = `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;

  let inheritedSupplementaryUrl: string | null = null;
  let inheritedSupplementaryRows = 0;
  const bills: TokorozawaOfficialBill[] = [];

  for (const row of table.querySelectorAll("tr")) {
    const cells = [...row.querySelectorAll(":scope > td")];
    const billNumber = normalizeText(cells[0]?.textContent);
    if (!BILL_NUMBER_PATTERN.test(billNumber)) continue;

    const links = [...row.querySelectorAll<HTMLAnchorElement>(":scope > td a")];
    const billLink = links.find((link) =>
      normalizeText(link.textContent).startsWith("議案("),
    );
    const supplementaryLink = links.find((link) =>
      normalizeText(link.textContent).startsWith("資料("),
    );
    if (supplementaryLink) {
      inheritedSupplementaryUrl = supplementaryLink.href;
      inheritedSupplementaryRows = Number(
        supplementaryLink.closest("td")?.getAttribute("rowspan") ?? "1",
      );
    }

    const responsibleDepartment = normalizeText(cells.at(-1)?.textContent);
    if (!billLink || !responsibleDepartment) {
      throw new Error(`${billNumber}の資料または所管を取得できませんでした`);
    }

    bills.push({
      municipalityName: "所沢市",
      meetingName,
      billNumber,
      title: requiredText(normalizeText(cells[1]?.textContent), `${billNumber}の件名`),
      submittingBody: "市長",
      responsibleDepartment,
      officialPageUrl,
      billDocumentUrl: billLink.href,
      supplementaryDocumentUrl:
        inheritedSupplementaryRows > 0 ? inheritedSupplementaryUrl : null,
      sourcePublishedAt,
    });

    if (inheritedSupplementaryRows > 0) inheritedSupplementaryRows -= 1;
    if (inheritedSupplementaryRows === 0) inheritedSupplementaryUrl = null;
  }

  if (bills.length === 0) throw new Error("議案が1件も見つかりませんでした");
  return bills;
};
