-- Source checked 2026-09-09: bill 86 PDF, first page, submitted 2026-09-01.
-- Idempotent: no inference from the general council schedule.
insert into public.municipal_deliberation_events (
  bill_id, event_type, event_date, body_name, summary, source_url, display_order
)
select id, 'submitted', '2026-09-01', '所沢市議会',
  '市長が議案第86号を提出（議案本文に記載）',
  'https://www.city.tokorozawa.saitama.jp/shiseijoho/shichougian/reiwa8nendai5kaiteireikai.files/R8-gian-086.pdf', 10
from public.bills
where id = '91f6e748-79c7-4f8a-a27a-18a124767a0e'
  and name = '令和8年度所沢市所沢都市計画事業狭山ケ丘土地区画整理特別会計補正予算（第1号）'
  and not exists (
    select 1 from public.municipal_deliberation_events
    where bill_id = bills.id and event_type = 'submitted' and event_date = '2026-09-01'
  );
