-- 所沢市の公式情報を取り込み済みの議案を「掲載準備中」として公開する。
-- 解説本文が未作成の議案を published にしないことで、未確認の要約は表示しない。
BEGIN;

UPDATE bills AS b
SET publish_status = 'coming_soon'
FROM municipal_bill_metadata AS m
WHERE m.bill_id = b.id
  AND m.municipality_name = '所沢市'
  AND b.publish_status = 'draft';

COMMIT;

-- 実行後の確認用。coming_soon が41件、draft が0件なら完了。
SELECT b.publish_status, count(*) AS bill_count
FROM bills AS b
JOIN municipal_bill_metadata AS m ON m.bill_id = b.id
WHERE m.municipality_name = '所沢市'
GROUP BY b.publish_status
ORDER BY b.publish_status;
