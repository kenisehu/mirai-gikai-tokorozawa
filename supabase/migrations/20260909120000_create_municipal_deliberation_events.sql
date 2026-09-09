create table municipal_deliberation_events (
  id uuid primary key default gen_random_uuid(),
  bill_id uuid not null references bills(id) on delete cascade,
  event_type text not null,
  event_date date,
  body_name text,
  summary text not null,
  question text,
  answer text,
  result text,
  source_url text not null,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  constraint municipal_deliberation_events_type_check
    check (event_type in ('submitted', 'question', 'committee', 'vote', 'minutes')),
  constraint municipal_deliberation_events_source_url_https
    check (source_url like 'https://%')
);

create index idx_municipal_deliberation_events_bill_order
  on municipal_deliberation_events (bill_id, display_order, event_date);

alter table municipal_deliberation_events enable row level security;

comment on table municipal_deliberation_events is
  '地方議会の議案ごとの上程、質疑、委員会審査、答弁、採決の経過';
