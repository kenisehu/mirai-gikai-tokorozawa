create table correction_reports (
  id uuid primary key default gen_random_uuid(),
  bill_id uuid references bills(id) on delete set null,
  bill_name text not null,
  page_url text not null,
  report_type text not null,
  location text,
  description text not null,
  source_url text,
  status text not null default 'new',
  created_at timestamptz not null default now(),
  constraint correction_reports_type_check
    check (report_type in ('factual_error', 'unclear', 'broken_link', 'other')),
  constraint correction_reports_status_check
    check (status in ('new', 'reviewing', 'resolved', 'dismissed')),
  constraint correction_reports_page_url_https check (page_url like 'https://%'),
  constraint correction_reports_source_url_https
    check (source_url is null or source_url like 'https://%'),
  constraint correction_reports_description_length
    check (char_length(description) between 10 and 2000)
);

create index idx_correction_reports_status_created
  on correction_reports (status, created_at desc);

alter table correction_reports enable row level security;

comment on table correction_reports is
  '公開ページの誤りや分かりにくい箇所について、個人情報なしで受け付ける非公開の報告';
