BEGIN;

WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和8年度所沢市一般会計補正予算（第2号）', 'HR', 'introduced',
    '議案第85号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第85号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第85号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第85号', '市長',
  '財政課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-085.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-085-089.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.736Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和8年度所沢市一般会計補正予算（第2号）',
    status_note = '議案第85号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第85号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）', 'HR', 'introduced',
    '議案第86号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第86号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第86号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第86号', '市長',
  '財政課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-086.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-085-089.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.739Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）',
    status_note = '議案第86号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第86号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和8年度所沢市国民健康保険特別会計補正予算（第1号）', 'HR', 'introduced',
    '議案第87号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第87号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第87号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第87号', '市長',
  '財政課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-087.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-085-089.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.741Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和8年度所沢市国民健康保険特別会計補正予算（第1号）',
    status_note = '議案第87号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第87号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和8年度所沢市介護保険特別会計補正予算（第1号）', 'HR', 'introduced',
    '議案第88号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第88号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第88号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第88号', '市長',
  '財政課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-088.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-085-089.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.742Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和8年度所沢市介護保険特別会計補正予算（第1号）',
    status_note = '議案第88号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第88号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和8年度所沢市後期高齢者医療特別会計補正予算（第1号）', 'HR', 'introduced',
    '議案第89号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第89号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第89号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第89号', '市長',
  '財政課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-089.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-085-089.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.743Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和8年度所沢市後期高齢者医療特別会計補正予算（第1号）',
    status_note = '議案第89号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第89号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市職員定数条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第90号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第90号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第90号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第90号', '市長',
  '経営企画課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-090.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-090.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.745Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市職員定数条例の一部を改正する条例制定について',
    status_note = '議案第90号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第90号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市一般職員の給与等に関する条例及び所沢市一般職員の特殊勤務手当に関する条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第91号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第91号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第91号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第91号', '市長',
  '職員課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-091.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-091.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.746Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市一般職員の給与等に関する条例及び所沢市一般職員の特殊勤務手当に関する条例の一部を改正する条例制定について',
    status_note = '議案第91号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第91号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市特定教育・保育施設及び特定地域型保育事業の運営に関する基準を定める条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第92号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第92号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第92号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第92号', '市長',
  'こども政策課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-092.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-092.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.747Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市特定教育・保育施設及び特定地域型保育事業の運営に関する基準を定める条例の一部を改正する条例制定について',
    status_note = '議案第92号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第92号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市家庭的保育事業等の設備及び運営に関する基準を定める条例等の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第93号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第93号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第93号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第93号', '市長',
  'こども政策課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-093.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-093.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.749Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市家庭的保育事業等の設備及び運営に関する基準を定める条例等の一部を改正する条例制定について',
    status_note = '議案第93号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第93号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市乳児等通園支援事業の設備及び運営に関する基準を定める条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第94号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第94号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第94号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第94号', '市長',
  'こども政策課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-094.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-094.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.751Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市乳児等通園支援事業の設備及び運営に関する基準を定める条例の一部を改正する条例制定について',
    status_note = '議案第94号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第94号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市病院事業の設置等に関する条例及び所沢市水道事業及び下水道事業の設置等に関する条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第95号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第95号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第95号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第95号', '市長',
  '市民医療センター事務部総務課・上下水道局総務課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-095.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-095.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.752Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市病院事業の設置等に関する条例及び所沢市水道事業及び下水道事業の設置等に関する条例の一部を改正する条例制定について',
    status_note = '議案第95号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第95号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市廃棄物の減量及び適正処理に関する条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第96号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第96号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第96号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第96号', '市長',
  '資源循環推進課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-096.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-096.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.753Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市廃棄物の減量及び適正処理に関する条例の一部を改正する条例制定について',
    status_note = '議案第96号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第96号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市ひと・まち・みどりの景観条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第97号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第97号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第97号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第97号', '市長',
  '都市計画課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-097.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-097.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.754Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市ひと・まち・みどりの景観条例の一部を改正する条例制定について',
    status_note = '議案第97号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第97号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢都市計画事業狭山ケ丘土地区画整理事業施行に関する条例及び所沢都市計画事業所沢駅西口土地区画整理事業施行に関する条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第98号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第98号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第98号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第98号', '市長',
  '狭山ケ丘区画整理事務所・市街地整備課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-098.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-098.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.756Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢都市計画事業狭山ケ丘土地区画整理事業施行に関する条例及び所沢都市計画事業所沢駅西口土地区画整理事業施行に関する条例の一部を改正する条例制定について',
    status_note = '議案第98号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第98号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市消防団条例及び所沢市非常勤消防団員に係る退職報償金の支給に関する条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第99号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第99号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第99号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第99号', '市長',
  '危機管理室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-099.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-099.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.757Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市消防団条例及び所沢市非常勤消防団員に係る退職報償金の支給に関する条例の一部を改正する条例制定について',
    status_note = '議案第99号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第99号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市消防団員等公務災害補償条例の一部を改正する条例制定について', 'HR', 'introduced',
    '議案第100号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第100号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第100号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第100号', '市長',
  '危機管理室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-100.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-100.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.758Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市消防団員等公務災害補償条例の一部を改正する条例制定について',
    status_note = '議案第100号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第100号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市民文化センターの指定管理者の指定について', 'HR', 'introduced',
    '議案第101号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第101号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第101号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第101号', '市長',
  '文化芸術振興課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-101.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-101.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.759Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市民文化センターの指定管理者の指定について',
    status_note = '議案第101号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第101号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市立かしの木学園の指定管理者の指定について', 'HR', 'introduced',
    '議案第102号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第102号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第102号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第102号', '市長',
  'こども福祉課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-102.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-102.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.760Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市立かしの木学園の指定管理者の指定について',
    status_note = '議案第102号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第102号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市立みどり児童館の指定管理者の指定について', 'HR', 'introduced',
    '議案第103号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第103号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第103号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第103号', '市長',
  '青少年課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-103.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-103.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.761Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市立みどり児童館の指定管理者の指定について',
    status_note = '議案第103号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第103号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    'ラーク所沢の指定管理者の指定について', 'HR', 'introduced',
    '議案第104号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第104号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第104号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第104号', '市長',
  '産業振興課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-104.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-104.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.762Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = 'ラーク所沢の指定管理者の指定について',
    status_note = '議案第104号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第104号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市観光情報・物産館の指定管理者の指定について', 'HR', 'introduced',
    '議案第105号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第105号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第105号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第105号', '市長',
  '商業観光課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-105.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-105.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.763Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市観光情報・物産館の指定管理者の指定について',
    status_note = '議案第105号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第105号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市パークゴルフ場の指定管理者の指定について', 'HR', 'introduced',
    '議案第106号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第106号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第106号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第106号', '市長',
  'スポーツ振興課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-106.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-106.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.764Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市パークゴルフ場の指定管理者の指定について',
    status_note = '議案第106号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第106号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市立所沢図書館所沢分館等の指定管理者の指定について', 'HR', 'introduced',
    '議案第107号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第107号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第107号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第107号', '市長',
  '所沢図書館', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-107.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-107.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.765Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市立所沢図書館所沢分館等の指定管理者の指定について',
    status_note = '議案第107号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第107号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市立所沢図書館新所沢分館等の指定管理者の指定について', 'HR', 'introduced',
    '議案第108号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第108号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第108号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第108号', '市長',
  '所沢図書館', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-108.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-108.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.767Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市立所沢図書館新所沢分館等の指定管理者の指定について',
    status_note = '議案第108号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第108号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市学校給食センター再整備事業契約締結についての一部変更について', 'HR', 'introduced',
    '議案第109号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第109号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第109号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第109号', '市長',
  '保健給食課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-109.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-109.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.768Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市学校給食センター再整備事業契約締結についての一部変更について',
    status_note = '議案第109号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第109号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '北野下富線（4工区）道路築造工事（下部工その3外）請負契約締結について', 'HR', 'introduced',
    '議案第110号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第110号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第110号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第110号', '市長',
  '道路建設課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-110.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-110.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.770Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '北野下富線（4工区）道路築造工事（下部工その3外）請負契約締結について',
    status_note = '議案第110号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第110号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '所沢市立安松小学校長寿命化改修（電気設備）工事（2／2）請負契約締結について', 'HR', 'introduced',
    '議案第111号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第111号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第111号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第111号', '市長',
  '教育施設課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-111.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-111.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.771Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '所沢市立安松小学校長寿命化改修（電気設備）工事（2／2）請負契約締結について',
    status_note = '議案第111号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第111号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    'くぬぎ山特別緑地保全地区内の土地の取得について', 'HR', 'introduced',
    '議案第112号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第112号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第112号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第112号', '市長',
  'みどり自然課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-112.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-112.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.773Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = 'くぬぎ山特別緑地保全地区内の土地の取得について',
    status_note = '議案第112号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第112号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '市道路線の認定について', 'HR', 'introduced',
    '議案第113号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '議案第113号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '議案第113号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '議案第113号', '市長',
  '建設総務課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-113.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-siryou-113.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.774Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '市道路線の認定について',
    status_note = '議案第113号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '議案第113号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '産業廃棄物処理業計画書（処分業）に係る意見を求めることについて', 'HR', 'introduced',
    '諮問第2号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '諮問第2号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '諮問第2号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '諮問第2号', '市長',
  '資源循環推進課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-shimon-002.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-shimonsiryou-002.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.776Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '産業廃棄物処理業計画書（処分業）に係る意見を求めることについて',
    status_note = '諮問第2号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '諮問第2号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '産業廃棄物処理業計画書（収集運搬業）に係る意見を求めることについて', 'HR', 'introduced',
    '諮問第3号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '諮問第3号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '諮問第3号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '諮問第3号', '市長',
  '資源循環推進課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-shimon-003.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-shimonsiryou-003.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.777Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '産業廃棄物処理業計画書（収集運搬業）に係る意見を求めることについて',
    status_note = '諮問第3号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '諮問第3号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市一般会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第1号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第1号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第1号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第1号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-001.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-001.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.778Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市一般会計歳入歳出決算の認定について',
    status_note = '認定第1号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第1号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市交通災害共済特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第2号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第2号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第2号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第2号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-002.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-002.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.778Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市交通災害共済特別会計歳入歳出決算の認定について',
    status_note = '認定第2号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第2号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第3号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第3号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第3号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第3号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-003.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-003.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.779Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計歳入歳出決算の認定について',
    status_note = '認定第3号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第3号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市所沢都市計画事業所沢駅西口土地区画整理特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第4号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第4号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第4号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第4号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-004.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-004.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.780Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市所沢都市計画事業所沢駅西口土地区画整理特別会計歳入歳出決算の認定について',
    status_note = '認定第4号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第4号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市国民健康保険特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第5号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第5号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第5号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第5号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-005.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-005.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.780Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市国民健康保険特別会計歳入歳出決算の認定について',
    status_note = '認定第5号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第5号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市介護保険特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第6号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第6号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第6号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第6号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-006.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-006.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.781Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市介護保険特別会計歳入歳出決算の認定について',
    status_note = '認定第6号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第6号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市後期高齢者医療特別会計歳入歳出決算の認定について', 'HR', 'introduced',
    '認定第7号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第7号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第7号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第7号', '市長',
  '出納室', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-007.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-007.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.782Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市後期高齢者医療特別会計歳入歳出決算の認定について',
    status_note = '認定第7号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第7号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市水道事業決算の認定について', 'HR', 'introduced',
    '認定第8号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第8号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第8号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第8号', '市長',
  '上下水道局経営課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-008.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-008.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.784Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市水道事業決算の認定について',
    status_note = '認定第8号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第8号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市下水道事業決算の認定について', 'HR', 'introduced',
    '認定第9号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第9号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第9号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第9号', '市長',
  '上下水道局経営課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-009.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-009.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.785Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市下水道事業決算の認定について',
    status_note = '認定第9号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第9号';


WITH inserted_bill AS (
  INSERT INTO bills (
    name, originating_house, status, status_note, submitted_date,
    publish_status, is_featured, is_review_completed
  )
  SELECT
    '令和7年度所沢市病院事業決算の認定について', 'HR', 'introduced',
    '認定第10号 所沢市議会へ市長提出',
    '2026-09-01T00:00:00+09:00'::timestamptz,
    'draft', false, false
  WHERE NOT EXISTS (
    SELECT 1 FROM municipal_bill_metadata
    WHERE municipality_name = '所沢市'
      AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
      AND bill_number = '認定第10号'
  )
  RETURNING id
), target_bill AS (
  SELECT id FROM inserted_bill
  UNION ALL
  SELECT bill_id AS id FROM municipal_bill_metadata
  WHERE municipality_name = '所沢市'
    AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
    AND bill_number = '認定第10号'
)
INSERT INTO municipal_bill_metadata (
  bill_id, municipality_name, meeting_name, bill_number, submitting_body,
  responsible_department, official_page_url, bill_document_url,
  supplementary_document_url, source_published_at, source_retrieved_at
)
SELECT
  id, '所沢市', '令和8年第5回(9月)定例会議市長提出議案', '認定第10号', '市長',
  '市民医療センター事務部総務課', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.html',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/nintei-R08-010.pdf', 'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/ninteisiryo-R08-010.pdf',
  '2026-09-01T00:00:00+09:00'::timestamptz,
  '2026-09-05T13:24:11.786Z'::timestamptz
FROM target_bill
ON CONFLICT (municipality_name, meeting_name, bill_number) DO UPDATE SET
  responsible_department = EXCLUDED.responsible_department,
  official_page_url = EXCLUDED.official_page_url,
  bill_document_url = EXCLUDED.bill_document_url,
  supplementary_document_url = EXCLUDED.supplementary_document_url,
  source_published_at = EXCLUDED.source_published_at,
  source_retrieved_at = EXCLUDED.source_retrieved_at;

UPDATE bills b
SET name = '令和7年度所沢市病院事業決算の認定について',
    status_note = '認定第10号 所沢市議会へ市長提出',
    submitted_date = '2026-09-01T00:00:00+09:00'::timestamptz
FROM municipal_bill_metadata m
WHERE b.id = m.bill_id
  AND m.municipality_name = '所沢市'
  AND m.meeting_name = '令和8年第5回(9月)定例会議市長提出議案'
  AND m.bill_number = '認定第10号';

COMMIT;
