"""Mechanically extract bill number, committee, and decision from official PDFs."""
import json
import re
from pathlib import Path
import pdfplumber

root = Path(__file__).resolve().parent.parent
output = {}
for slug, filename, count in [
    ("2026-06", "june-results.pdf", 40),
    ("2026-02", "feb-results.pdf", 42),
]:
    records = {}
    with pdfplumber.open(root / "tmp/pdfs" / filename) as pdf:
        for page_number, page in enumerate(pdf.pages, 1):
            for line in page.extract_text().splitlines():
                number = re.search(r"(議案|諮問)第(\d+)号", line)
                if not number:
                    continue
                decision = re.search(r"(原案可決|可\s*決|否\s*決|同意する)$", line)
                committee = re.search(r"(予\s*算|総務経済|市民文教|建設環境|健康福祉|＿|-)\s+[〇○×]", line)
                if not decision or not committee:
                    raise ValueError(line)
                key = ("inquiry-" if number[1] == "諮問" else "bill-") + number[2]
                records[key] = {
                    "committee": re.sub(r"\s", "", committee[1]),
                    "result": re.sub(r"\s", "", decision[1]),
                    "resultPage": page_number,
                }
    if len(records) != count:
        raise ValueError(f"{slug}: {len(records)} != {count}")
    output[slug] = records
(root / "web/src/features/session-archive/shared/official-results.json").write_text(
    json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print("82 decisions and committee references extracted")
