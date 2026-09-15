-- Isolated regression test. Public tables are SELECT-only sources.
-- All writes/functions are in pg_temp, CTAS copies have no public defaults,
-- triggers or foreign keys, and the entire test ends with ROLLBACK.
-- Embedded production SQL must match record-tokorozawa-september-results.sql
-- with only its outer BEGIN; and COMMIT; removed.
BEGIN;
SET LOCAL search_path = pg_temp, public;

CREATE TEMP TABLE municipal_bill_metadata ON COMMIT DROP AS
SELECT * FROM public.municipal_bill_metadata
WHERE municipality_name = '所沢市'
  AND meeting_name = '令和8年第5回(9月)定例会議市長提出議案';
CREATE TEMP TABLE bills ON COMMIT DROP AS
SELECT b.* FROM public.bills b
JOIN pg_temp.municipal_bill_metadata m ON m.bill_id = b.id;
CREATE TEMP TABLE municipal_deliberation_events ON COMMIT DROP AS
SELECT e.* FROM public.municipal_deliberation_events e
JOIN pg_temp.municipal_bill_metadata m USING (bill_id);

DO $safety$
BEGIN
  IF (SELECT count(*) FROM pg_temp.municipal_bill_metadata) <> 41
    OR (SELECT count(DISTINCT bill_number) FROM pg_temp.municipal_bill_metadata) <> 41
    OR (SELECT count(*) FROM pg_temp.bills) <> 41
  THEN RAISE EXCEPTION 'Fixture requires 41 distinct September bills'; END IF;
  IF 'municipal_bill_metadata'::regclass <> 'pg_temp.municipal_bill_metadata'::regclass
    OR 'bills'::regclass <> 'pg_temp.bills'::regclass
    OR 'municipal_deliberation_events'::regclass <> 'pg_temp.municipal_deliberation_events'::regclass
  THEN RAISE EXCEPTION 'Unsafe table resolution'; END IF;
END
$safety$;

-- Recreate the pre-release state only in the temporary copies. This lets the
-- same regression test run both before and after the real release.
UPDATE pg_temp.municipal_bill_metadata SET deliberation_result = NULL;
UPDATE pg_temp.bills SET status = 'introduced', status_note = NULL;
DELETE FROM pg_temp.municipal_deliberation_events
WHERE event_type = 'vote';

CREATE TEMP TABLE test_script (sql text) ON COMMIT DROP;
INSERT INTO pg_temp.test_script VALUES ($production$
-- Source: shityokekka_R8.9.14.pdf, checked 2026-09-15.
-- Scoped, atomic and repeatable. Does not infer final approval for accounts.
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
$production$);

CREATE FUNCTION pg_temp.test_state() RETURNS jsonb LANGUAGE sql AS $state$
  SELECT jsonb_build_object(
    'metadata', (SELECT jsonb_agg(to_jsonb(m) ORDER BY to_jsonb(m)::text) FROM pg_temp.municipal_bill_metadata m),
    'bills', (SELECT jsonb_agg(to_jsonb(b) ORDER BY to_jsonb(b)::text) FROM pg_temp.bills b),
    'events', (SELECT jsonb_agg(to_jsonb(e) ORDER BY to_jsonb(e)::text) FROM pg_temp.municipal_deliberation_events e)
  );
$state$;

CREATE TEMP TABLE test_outcomes (scenario text, outcome text) ON COMMIT DROP;
DO $test$
DECLARE
  source_sql text := (SELECT sql FROM pg_temp.test_script);
  first_state jsonb;
BEGIN
  EXECUTE source_sql;
  IF (SELECT count(*) FROM pg_temp.municipal_deliberation_events WHERE event_type = 'vote') <> 31
    OR (SELECT count(*) FROM pg_temp.bills WHERE status = 'enacted') <> 31
    OR (SELECT count(*) FROM pg_temp.bills WHERE status = 'in_originating_house') <> 10
    OR (SELECT count(*) FROM pg_temp.municipal_bill_metadata WHERE deliberation_result = '原案可決') <> 16
    OR (SELECT count(*) FROM pg_temp.municipal_bill_metadata WHERE deliberation_result = '可決') <> 13
    OR (SELECT count(*) FROM pg_temp.municipal_bill_metadata WHERE deliberation_result = '回答する') <> 2
  THEN RAISE EXCEPTION 'First run did not produce expected results'; END IF;
  INSERT INTO pg_temp.test_outcomes VALUES ('initial application: 31 votes, 10 pending accounts', 'PASS');
  first_state := pg_temp.test_state();
  -- Models ON COMMIT DROP between separate production executions without
  -- committing any part of this isolated test transaction.
  DROP TABLE pg_temp.september_results;
  EXECUTE source_sql;
  IF pg_temp.test_state() IS DISTINCT FROM first_state
  THEN RAISE EXCEPTION 'Second run changed data or duplicated events'; END IF;
  INSERT INTO pg_temp.test_outcomes VALUES ('second application: identical state and 31 votes', 'PASS');
  DROP TABLE pg_temp.september_results;
END
$test$;

CREATE TEMP TABLE baseline_metadata ON COMMIT DROP AS TABLE pg_temp.municipal_bill_metadata;
CREATE TEMP TABLE baseline_bills ON COMMIT DROP AS TABLE pg_temp.bills;
CREATE TEMP TABLE baseline_events ON COMMIT DROP AS TABLE pg_temp.municipal_deliberation_events;

DO $negative$
DECLARE
  scenario text;
  expected_message text;
  caught_message text;
  before_attempt jsonb;
  source_sql text := (SELECT sql FROM pg_temp.test_script);
BEGIN
  FOREACH scenario IN ARRAY ARRAY['duplicate number', 'missing record', 'future vote', 'same-day conflict', 'metadata conflict'] LOOP
    TRUNCATE pg_temp.municipal_bill_metadata, pg_temp.bills, pg_temp.municipal_deliberation_events;
    INSERT INTO pg_temp.municipal_bill_metadata SELECT * FROM pg_temp.baseline_metadata;
    INSERT INTO pg_temp.bills SELECT * FROM pg_temp.baseline_bills;
    INSERT INTO pg_temp.municipal_deliberation_events SELECT * FROM pg_temp.baseline_events;
    expected_message := 'Newer or conflicting results exist; review instead of overwriting';
    CASE scenario
      WHEN 'duplicate number' THEN
        -- Keep 41 rows and 31 decisions, exercising the DISTINCT guard alone.
        UPDATE pg_temp.municipal_bill_metadata SET bill_number = '議案第85号' WHERE bill_number = '議案第86号';
        expected_message := 'Expected exactly 41 identified September records (31 decisions)';
      WHEN 'missing record' THEN
        DELETE FROM pg_temp.municipal_bill_metadata WHERE bill_number = '認定第10号';
        expected_message := 'Expected exactly 41 identified September records (31 decisions)';
      WHEN 'future vote' THEN
        UPDATE pg_temp.municipal_deliberation_events SET event_date = '2026-09-30'
        WHERE event_type = 'vote' AND bill_id = (SELECT bill_id FROM pg_temp.municipal_bill_metadata WHERE bill_number = '議案第85号');
      WHEN 'same-day conflict' THEN
        UPDATE pg_temp.municipal_deliberation_events SET result = '否決'
        WHERE event_type = 'vote' AND bill_id = (SELECT bill_id FROM pg_temp.municipal_bill_metadata WHERE bill_number = '議案第85号');
      WHEN 'metadata conflict' THEN
        UPDATE pg_temp.municipal_bill_metadata SET deliberation_result = '認定' WHERE bill_number = '認定第1号';
    END CASE;
    before_attempt := pg_temp.test_state();
    caught_message := NULL;
    BEGIN
      EXECUTE source_sql;
    EXCEPTION WHEN raise_exception THEN
      GET STACKED DIAGNOSTICS caught_message = MESSAGE_TEXT;
    END;
    IF caught_message IS DISTINCT FROM expected_message
    THEN RAISE EXCEPTION 'Scenario %: expected rejection %, got %', scenario, expected_message, caught_message; END IF;
    IF pg_temp.test_state() IS DISTINCT FROM before_attempt
      OR to_regclass('pg_temp.september_results') IS NOT NULL
    THEN RAISE EXCEPTION 'Scenario %: failed operation did not fully roll back', scenario; END IF;
    INSERT INTO pg_temp.test_outcomes VALUES (scenario || ': rejected, all three tables unchanged', 'PASS');
  END LOOP;
END
$negative$;

-- Expected: seven PASS rows. Any unexpected result raises and aborts the test.
SELECT * FROM pg_temp.test_outcomes ORDER BY scenario;
ROLLBACK;
