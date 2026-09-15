-- Source: shityokekka_R8.9.14.pdf, checked 2026-09-15.
-- Scoped, atomic and repeatable. Does not infer final approval for accounts.
BEGIN;
CREATE TEMP TABLE september_results ON COMMIT DROP AS
SELECT m.bill_id, m.bill_number,
  CASE
    WHEN m.bill_number IN ('諮問第2号','諮問第3号') THEN '回答する'
    WHEN m.bill_number ~ '^認定第([1-9]|10)号$' THEN '決算特別委員会に付託（最終結果未確認）'
    WHEN m.bill_number ~ '^議案第(8[5-9]|9[0-9]|100)号$' THEN '原案可決'
    WHEN m.bill_number ~ '^議案第(10[1-9]|11[0-3])号$' THEN '可決'
  END AS result
FROM municipal_bill_metadata m
WHERE m.municipality_name='所沢市'
  AND m.meeting_name='令和8年第5回(9月)定例会議市長提出議案';
DO $$ BEGIN
  IF (SELECT count(*) FROM september_results) <> 41
    OR (SELECT count(DISTINCT bill_number) FROM september_results) <> 41
    OR (SELECT count(*) FROM september_results WHERE result IN ('原案可決','可決','回答する')) <> 31
    OR EXISTS (SELECT 1 FROM september_results WHERE result IS NULL)
  THEN RAISE EXCEPTION 'Expected exactly 41 identified September records (31 decisions)'; END IF;
  IF EXISTS (
    SELECT 1 FROM municipal_bill_metadata m JOIN september_results r USING (bill_id)
    WHERE m.deliberation_result IS NOT NULL AND m.deliberation_result <> r.result
  ) OR EXISTS (
    SELECT 1 FROM municipal_deliberation_events e JOIN september_results r USING (bill_id)
    WHERE e.event_type='vote' AND (e.event_date > '2026-09-14'
      OR (e.event_date='2026-09-14' AND e.result IS DISTINCT FROM r.result))
  ) THEN RAISE EXCEPTION 'Newer or conflicting results exist; review instead of overwriting'; END IF;
END $$;
UPDATE municipal_bill_metadata m
SET deliberation_result=r.result
FROM september_results r WHERE m.bill_id=r.bill_id;
UPDATE bills b
SET status=CASE WHEN r.result LIKE '決算%' THEN 'in_originating_house' ELSE 'enacted' END::bill_status_enum,
    status_note=r.bill_number || '：' || r.result || CASE WHEN r.result LIKE '決算%' THEN '' ELSE '（2026年9月14日）' END
FROM september_results r WHERE b.id=r.bill_id;
INSERT INTO municipal_deliberation_events
  (bill_id,event_type,event_date,body_name,summary,result,source_url,display_order)
SELECT r.bill_id,'vote','2026-09-14','所沢市議会',
  r.bill_number || 'の審議結果を公式資料で確認',r.result,
  'https://www.city.tokorozawa.saitama.jp/shigikai/shingi/r8dai5/r8_9shingikekka.files/shityokekka_R8.9.14.pdf',40
FROM september_results r
WHERE r.result IN ('原案可決','可決','回答する')
  AND NOT EXISTS (SELECT 1 FROM municipal_deliberation_events e
    WHERE e.bill_id=r.bill_id AND e.event_type='vote' AND e.event_date='2026-09-14');
SELECT result,count(*) FROM september_results GROUP BY result ORDER BY result;
COMMIT;
