-- 地方議会の公開情報を、国会向けの既存 bills スキーマを壊さず保持する。
create table municipal_bill_metadata (
  bill_id uuid primary key references bills(id) on delete cascade,
  municipality_name text not null,
  meeting_name text not null,
  bill_number text not null,
  submitting_body text,
  responsible_department text,
  official_page_url text not null,
  bill_document_url text,
  supplementary_document_url text,
  deliberation_result text,
  source_published_at timestamptz,
  source_retrieved_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint municipal_bill_metadata_official_page_url_https
    check (official_page_url like 'https://%'),
  constraint municipal_bill_metadata_bill_document_url_https
    check (bill_document_url is null or bill_document_url like 'https://%'),
  constraint municipal_bill_metadata_supplementary_document_url_https
    check (
      supplementary_document_url is null
      or supplementary_document_url like 'https://%'
    ),
  unique (municipality_name, meeting_name, bill_number)
);

create index idx_municipal_bill_metadata_meeting
  on municipal_bill_metadata (municipality_name, meeting_name);

create trigger update_municipal_bill_metadata_updated_at
  before update on municipal_bill_metadata
  for each row execute function update_updated_at_column();

alter table municipal_bill_metadata enable row level security;

comment on table municipal_bill_metadata is
  '地方議会の議案番号、会議名、公式資料URL、出典取得日時を保持する';
comment on column municipal_bill_metadata.source_retrieved_at is
  '公式情報を確認・取得した日時';
