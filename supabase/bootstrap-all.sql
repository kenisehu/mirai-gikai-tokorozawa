BEGIN;
-- Enable extensions schema & uuid-ossp
create schema if not exists extensions;
create extension if not exists "uuid-ossp" with schema extensions;

-- Create ENUM types
CREATE TYPE house_enum AS ENUM ('HR', 'HC');
CREATE TYPE bill_status_enum AS ENUM (
    'introduced',
    'in_originating_house',
    'in_receiving_house',
    'enacted',
    'rejected'
);
CREATE TYPE stance_type_enum AS ENUM ('for', 'against', 'neutral');
CREATE TYPE chat_role_enum AS ENUM ('user', 'system', 'assistant');

-- Create bills table
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name TEXT NOT NULL,
    headline TEXT,
    description TEXT,
    originating_house house_enum NOT NULL,
    status bill_status_enum NOT NULL,
    status_note TEXT,
    published_at TIMESTAMP WITH TIME ZONE NOT NULL,
    body_markdown TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create mirai_stances table
CREATE TABLE mirai_stances (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    bill_id UUID NOT NULL UNIQUE REFERENCES bills(id) ON DELETE CASCADE,
    type stance_type_enum NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create chats table
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
    user_id UUID,
    role chat_role_enum NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for bills table
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_published_at ON bills(published_at DESC);
CREATE INDEX idx_bills_originating_house ON bills(originating_house);

-- Create indexes for mirai_stances table
CREATE INDEX idx_mirai_stances_bill_id ON mirai_stances(bill_id);
CREATE INDEX idx_mirai_stances_type ON mirai_stances(type);

-- Create indexes for chats table
CREATE INDEX idx_chats_bill_id ON chats(bill_id);
CREATE INDEX idx_chats_user_id ON chats(user_id);
CREATE INDEX idx_chats_created_at ON chats(created_at DESC);
CREATE INDEX idx_chats_bill_user ON chats(bill_id, user_id);

-- Create function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_bills_updated_at BEFORE UPDATE ON bills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mirai_stances_updated_at BEFORE UPDATE ON mirai_stances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chats_updated_at BEFORE UPDATE ON chats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (all access denied by default)
ALTER TABLE bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE mirai_stances ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- No policies are created, so all access is denied by default
-- Access will only be possible using Supabase Service Role Key from server-side

-- Add comments to tables and columns for documentation
COMMENT ON TABLE bills IS '議案の基本情報を管理するテーブル';
COMMENT ON COLUMN bills.originating_house IS '発議院（HR:衆議院, HC:参議院）';
COMMENT ON COLUMN bills.status IS '議案のステータス';
COMMENT ON COLUMN bills.published_at IS 'サービスでの議案公開日時';

COMMENT ON TABLE mirai_stances IS 'チームみらい（安野議員）の公式スタンスを記録するテーブル';
COMMENT ON COLUMN mirai_stances.type IS 'スタンス（for:賛成, against:反対, neutral:中立）';

COMMENT ON TABLE chats IS 'AIとの対話履歴を管理するテーブル';
COMMENT ON COLUMN chats.user_id IS 'ユーザーID（Supabase匿名認証）';
COMMENT ON COLUMN chats.role IS 'メッセージの送信者役割';
-- Create ENUM type for difficulty levels
CREATE TYPE difficulty_level_enum AS ENUM ('easy', 'normal', 'hard');

-- Create bill_contents table
CREATE TABLE bill_contents (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  difficulty_level difficulty_level_enum NOT NULL,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  content TEXT NOT NULL, -- Markdown形式
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(bill_id, difficulty_level)
);

-- Create indexes
CREATE INDEX idx_bill_contents_bill_id ON bill_contents(bill_id);
CREATE INDEX idx_bill_contents_difficulty ON bill_contents(difficulty_level);

-- Create trigger for updated_at
CREATE TRIGGER update_bill_contents_updated_at BEFORE UPDATE ON bill_contents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE bill_contents ENABLE ROW LEVEL SECURITY;

-- Add table comments
COMMENT ON TABLE bill_contents IS '議案の難易度別コンテンツを管理するテーブル';
COMMENT ON COLUMN bill_contents.difficulty_level IS '難易度レベル（easy:やさしい, normal:ふつう, hard:難しい）';
COMMENT ON COLUMN bill_contents.content IS 'Markdown形式の議案内容';
-- マイグレーション: billsテーブルから不要になったカラムを削除
-- bill_contentsテーブルに移行したため、以下のカラムが不要となった

-- headline, description, body_markdownカラムを削除
ALTER TABLE bills DROP COLUMN IF EXISTS headline;
ALTER TABLE bills DROP COLUMN IF EXISTS description;
ALTER TABLE bills DROP COLUMN IF EXISTS body_markdown;

-- コメント更新
COMMENT ON TABLE bills IS '議案の基本情報を格納するテーブル。コンテンツはbill_contentsテーブルで管理。';
-- Create storage bucket for bill thumbnails
INSERT INTO storage.buckets (id, name, public) VALUES ('bill-thumbnails', 'bill-thumbnails', true);

-- Create policy to allow public read access to bill thumbnails
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'bill-thumbnails');

-- Create policy to allow authenticated users to upload/update bill thumbnails
CREATE POLICY "Authenticated users can upload bill thumbnails" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'bill-thumbnails' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update bill thumbnails" ON storage.objects FOR UPDATE USING (bucket_id = 'bill-thumbnails' AND auth.role() = 'authenticated');

-- Create policy to allow authenticated users to delete bill thumbnails
CREATE POLICY "Authenticated users can delete bill thumbnails" ON storage.objects FOR DELETE USING (bucket_id = 'bill-thumbnails' AND auth.role() = 'authenticated');

-- Add thumbnail_url column to bills table
ALTER TABLE bills ADD COLUMN thumbnail_url TEXT;

-- Add comment for the new column
COMMENT ON COLUMN bills.thumbnail_url IS 'URL to the bill thumbnail image stored in Supabase Storage';
-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can upload bill thumbnails" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update bill thumbnails" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete bill thumbnails" ON storage.objects;

-- Create function to check if user has admin role in public schema
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    EXISTS (
      SELECT 1
      FROM auth.users
      WHERE id = auth.uid()
      AND raw_app_meta_data->>'roles' LIKE '%admin%'
    )
  );
END;
$$;

-- Create new policies with admin role requirement
CREATE POLICY "Admin users can upload bill thumbnails"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'bill-thumbnails'
  AND public.is_admin()
);

CREATE POLICY "Admin users can update bill thumbnails"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'bill-thumbnails'
  AND public.is_admin()
);

CREATE POLICY "Admin users can delete bill thumbnails"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'bill-thumbnails'
  AND public.is_admin()
);
-- Add publish_status column to bills table for managing draft/published state
-- Create ENUM type for bill publish status
CREATE TYPE bill_publish_status AS ENUM ('draft', 'published');

-- Add publish_status column with default value 'draft'
ALTER TABLE bills
ADD COLUMN publish_status bill_publish_status NOT NULL DEFAULT 'draft';

-- Create index for efficient filtering
CREATE INDEX idx_bills_publish_status ON bills(publish_status);

-- Update all existing bills to 'published' status
-- Since they were already public before this migration
UPDATE bills SET publish_status = 'published';

-- Add comment for documentation
COMMENT ON COLUMN bills.publish_status IS 'Publication status: draft (private) or published (public)';
COMMENT ON TYPE bill_publish_status IS 'ENUM type for bill publication status';
-- Create preview_tokens table for managing preview access
CREATE TABLE preview_tokens (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by TEXT
);

-- Create index for efficient token lookup
CREATE INDEX idx_preview_tokens_token ON preview_tokens(token);
CREATE INDEX idx_preview_tokens_bill_id ON preview_tokens(bill_id);
CREATE INDEX idx_preview_tokens_expires_at ON preview_tokens(expires_at);

-- Enable RLS
ALTER TABLE preview_tokens ENABLE ROW LEVEL SECURITY;

-- Add comment for documentation
COMMENT ON TABLE preview_tokens IS 'Preview tokens for bill access management';
COMMENT ON COLUMN preview_tokens.token IS 'Unique preview access token';
COMMENT ON COLUMN preview_tokens.expires_at IS 'Token expiration date (30 days)';
-- Add 'preparing' status to bill_status_enum
ALTER TYPE bill_status_enum ADD VALUE 'preparing';
-- スタンスタイプの拡張
-- 既存: for (賛成), against (反対), neutral (中立)
-- 追加: conditional_for (条件付き賛成), conditional_against (条件付き反対), considering (検討中)

-- 新しいENUM型を作成
CREATE TYPE stance_type_enum_new AS ENUM (
    'for',                    -- 賛成
    'against',                -- 反対
    'neutral',                -- 中立
    'conditional_for',        -- 条件付き賛成
    'conditional_against',    -- 条件付き反対
    'considering'            -- 検討中
);

-- 既存のカラムを新しいENUM型に変更
ALTER TABLE mirai_stances
    ALTER COLUMN type TYPE stance_type_enum_new
    USING type::text::stance_type_enum_new;

-- 古いENUM型を削除
DROP TYPE stance_type_enum;

-- 新しいENUM型の名前を元の名前に変更
ALTER TYPE stance_type_enum_new RENAME TO stance_type_enum;

-- コメントを更新
COMMENT ON COLUMN mirai_stances.type IS 'スタンス（for:賛成, against:反対, neutral:中立, conditional_for:条件付き賛成, conditional_against:条件付き反対, considering:検討中）';
-- Remove 'easy' from difficulty_level_enum
-- First, create a new enum without 'easy'
CREATE TYPE difficulty_level_enum_new AS ENUM ('normal', 'hard');

-- Delete existing 'easy' records to avoid conflicts
DELETE FROM bill_contents WHERE difficulty_level = 'easy';

-- Update the column to use the new enum
ALTER TABLE bill_contents
  ALTER COLUMN difficulty_level TYPE difficulty_level_enum_new
  USING difficulty_level::text::difficulty_level_enum_new;

-- Drop the old enum and rename the new one
DROP TYPE difficulty_level_enum;
ALTER TYPE difficulty_level_enum_new RENAME TO difficulty_level_enum;

-- Update table comment
COMMENT ON COLUMN bill_contents.difficulty_level IS '難易度レベル（normal:ふつう, hard:難しい）';
-- Create tags table
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create bills_tags junction table
CREATE TABLE bills_tags (
    bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (bill_id, tag_id)
);

-- Create trigger for tags updated_at
CREATE TRIGGER update_tags_updated_at BEFORE UPDATE ON tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE bills_tags ENABLE ROW LEVEL SECURITY;

-- No policies are created, so all access is denied by default
-- Access will only be possible using Supabase Service Role Key from server-side

-- Add comments for documentation
COMMENT ON TABLE tags IS 'Master table for tags';
COMMENT ON COLUMN tags.label IS 'Tag label (display name)';

COMMENT ON TABLE bills_tags IS 'Junction table for bills and tags relationship';
COMMENT ON COLUMN bills_tags.bill_id IS 'Bill ID';
COMMENT ON COLUMN bills_tags.tag_id IS 'Tag ID';
-- Add is_featured column to bills table
ALTER TABLE bills
ADD COLUMN is_featured BOOLEAN DEFAULT FALSE NOT NULL;

-- Add index for efficient querying of featured bills
CREATE INDEX idx_bills_is_featured ON bills(is_featured) WHERE is_featured = TRUE;

-- Add comment for documentation
COMMENT ON COLUMN bills.is_featured IS 'Flag to indicate if this bill is featured on the homepage';
-- Create diet_sessions table
CREATE TABLE diet_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT end_date_after_start_date CHECK (end_date >= start_date)
);

-- Enable Row Level Security
ALTER TABLE diet_sessions ENABLE ROW LEVEL SECURITY;

-- Create index for date range queries
CREATE INDEX idx_diet_sessions_date_range ON diet_sessions (start_date, end_date);

-- Auto-update updated_at trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON diet_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
-- Add featured_priority column to tags table
ALTER TABLE tags
ADD COLUMN featured_priority integer DEFAULT NULL;

-- Add comment
COMMENT ON COLUMN tags.featured_priority IS 'Featured表示の優先度（数値が小さいほど優先度が高い）。NULLの場合は非表示';

-- Create index for efficient featured tags queries
CREATE INDEX idx_tags_featured_priority ON tags(featured_priority) WHERE featured_priority IS NOT NULL;
-- Add description column to tags table
ALTER TABLE tags
ADD COLUMN description text DEFAULT NULL;

COMMENT ON COLUMN tags.description IS 'Tag description text';
-- Make bills.published_at nullable
ALTER TABLE bills ALTER COLUMN published_at DROP NOT NULL;
ALTER TYPE stance_type_enum ADD VALUE 'continued_deliberation';
create table if not exists public.chat_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  session_id text,
  prompt_name text,
  model text not null,
  input_tokens integer not null default 0,
  output_tokens integer not null default 0,
  total_tokens integer not null default 0,
  cost_usd numeric(12, 6) not null default 0,
  metadata jsonb,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists chat_usage_events_user_id_occurred_at_idx
  on public.chat_usage_events (user_id, occurred_at);

alter table public.chat_usage_events enable row level security;
-- Add share_thumbnail_url column to bills table for Twitter/share OGP
ALTER TABLE bills ADD COLUMN share_thumbnail_url TEXT;

-- Add comment for the new column
COMMENT ON COLUMN bills.share_thumbnail_url IS 'URL to the share/Twitter OGP image stored in Supabase Storage';

-- Add 'coming_soon' to bill_publish_status enum
ALTER TYPE bill_publish_status ADD VALUE 'coming_soon';

-- Add shugiin_url column to bills table for linking to House of Representatives page
ALTER TABLE bills
ADD COLUMN shugiin_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN bills.shugiin_url IS 'URL to the House of Representatives (衆議院) page for this bill';

-- Add diet_session_id to bills table for linking bills to diet sessions
ALTER TABLE bills 
ADD COLUMN diet_session_id uuid REFERENCES diet_sessions(id) ON DELETE SET NULL;

-- Create index for querying bills by diet session
CREATE INDEX idx_bills_diet_session_id ON bills(diet_session_id);

-- Add comment for documentation
COMMENT ON COLUMN bills.diet_session_id IS '紐付けられた国会会期ID';

-- Add slug and shugiin_url columns to diet_sessions table

-- Add slug column for URL-friendly identifiers
ALTER TABLE diet_sessions
ADD COLUMN slug TEXT UNIQUE;

-- Create index for slug lookups
CREATE INDEX idx_diet_sessions_slug ON diet_sessions(slug);

-- Add shugiin_url column for linking to official 衆議院 page
ALTER TABLE diet_sessions
ADD COLUMN shugiin_url TEXT;

-- Add comments for documentation
COMMENT ON COLUMN diet_sessions.slug IS 'URL用のスラッグ（例: 219-rinji, 218-jokai）';
COMMENT ON COLUMN diet_sessions.shugiin_url IS '衆議院の国会議案情報ページURL';
-- Create ENUM types for interview feature
CREATE TYPE interview_config_status_enum AS ENUM ('public', 'closed');
CREATE TYPE interview_role_enum AS ENUM ('assistant', 'user');

-- Create interview_configs table
CREATE TABLE interview_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID NOT NULL UNIQUE REFERENCES bills(id) ON DELETE CASCADE,
  status interview_config_status_enum NOT NULL DEFAULT 'closed',
  themes TEXT[],
  knowledge_source TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create interview_questions table
CREATE TABLE interview_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_config_id UUID NOT NULL REFERENCES interview_configs(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  instruction TEXT,
  quick_replies TEXT[],
  question_order INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create interview_sessions table
CREATE TABLE interview_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_config_id UUID NOT NULL REFERENCES interview_configs(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  langfuse_session_id TEXT,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create interview_messages table
CREATE TABLE interview_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_session_id UUID NOT NULL REFERENCES interview_sessions(id) ON DELETE CASCADE,
  role interview_role_enum NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create interview_report table
CREATE TABLE interview_report (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_session_id UUID NOT NULL UNIQUE REFERENCES interview_sessions(id) ON DELETE CASCADE,
  summary TEXT,
  stance stance_type_enum,
  role TEXT,
  role_description TEXT,
  opinions JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for interview_configs
CREATE INDEX idx_interview_configs_status ON interview_configs(status);

-- Create indexes for interview_questions
CREATE INDEX idx_interview_questions_config_id ON interview_questions(interview_config_id);
CREATE INDEX idx_interview_questions_config_order ON interview_questions(interview_config_id, question_order);

-- Create indexes for interview_sessions
CREATE INDEX idx_interview_sessions_config_id ON interview_sessions(interview_config_id);
CREATE INDEX idx_interview_sessions_user_id ON interview_sessions(user_id);
CREATE INDEX idx_interview_sessions_config_user ON interview_sessions(interview_config_id, user_id);
CREATE INDEX idx_interview_sessions_started_at ON interview_sessions(started_at);

-- Create indexes for interview_messages
CREATE INDEX idx_interview_messages_session_id ON interview_messages(interview_session_id);
CREATE INDEX idx_interview_messages_session_created ON interview_messages(interview_session_id, created_at);

-- Create triggers for updated_at
CREATE TRIGGER update_interview_configs_updated_at BEFORE UPDATE ON interview_configs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_questions_updated_at BEFORE UPDATE ON interview_questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_sessions_updated_at BEFORE UPDATE ON interview_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_interview_report_updated_at BEFORE UPDATE ON interview_report
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE interview_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_report ENABLE ROW LEVEL SECURITY;

-- No policies are created, so all access is denied by default
-- Access will only be possible using Supabase Service Role Key from server-side

-- Add comments for documentation
COMMENT ON TABLE interview_configs IS '議案ごとのインタビュー設定を管理するテーブル';
COMMENT ON COLUMN interview_configs.bill_id IS '対象議案ID（1議案1設定）';
COMMENT ON COLUMN interview_configs.status IS '設定ステータス（public: 公開/有効, closed: 非公開/無効）';
COMMENT ON COLUMN interview_configs.themes IS 'テーマの配列';
COMMENT ON COLUMN interview_configs.knowledge_source IS '議案のコンテキスト情報';

COMMENT ON TABLE interview_questions IS '事前定義されたインタビュー質問を管理するテーブル';
COMMENT ON COLUMN interview_questions.interview_config_id IS 'インタビュー設定ID';
COMMENT ON COLUMN interview_questions.question IS '質問文';
COMMENT ON COLUMN interview_questions.instruction IS 'AIへの指示（質問の深掘り方法など）';
COMMENT ON COLUMN interview_questions.quick_replies IS 'ユーザーが選択できるクイックリプライ';
COMMENT ON COLUMN interview_questions.question_order IS '質問の順序';

COMMENT ON TABLE interview_sessions IS 'インタビューセッションを管理するテーブル';
COMMENT ON COLUMN interview_sessions.interview_config_id IS 'インタビュー設定ID';
COMMENT ON COLUMN interview_sessions.user_id IS 'ユーザーID（匿名認証）';
COMMENT ON COLUMN interview_sessions.langfuse_session_id IS 'LangfuseセッションID';
COMMENT ON COLUMN interview_sessions.started_at IS '開始日時';
COMMENT ON COLUMN interview_sessions.completed_at IS '完了日時';

COMMENT ON TABLE interview_messages IS 'インタビュー内の質問と回答を保存するテーブル';
COMMENT ON COLUMN interview_messages.interview_session_id IS 'インタビューセッションID';
COMMENT ON COLUMN interview_messages.role IS 'メッセージの役割（assistant: AIからの質問, user: ユーザーからの回答）';
COMMENT ON COLUMN interview_messages.content IS 'メッセージ内容';

COMMENT ON TABLE interview_report IS 'インタビュー結果のレポートを保存するテーブル（AIが自動生成）';
COMMENT ON COLUMN interview_report.interview_session_id IS 'インタビューセッションID（1セッション1レポート）';
COMMENT ON COLUMN interview_report.summary IS 'インタビュー要約';
COMMENT ON COLUMN interview_report.stance IS 'AIが分析したユーザーのスタンス';
COMMENT ON COLUMN interview_report.role IS 'AIが推論したユーザーの役割';
COMMENT ON COLUMN interview_report.role_description IS '役割の説明';
COMMENT ON COLUMN interview_report.opinions IS '意見の配列 [{title: string, content: string}, ...]';

-- Count messages per interview_session_id in a single query via RPC
CREATE OR REPLACE FUNCTION get_interview_message_counts(session_ids UUID[])
RETURNS TABLE (
  interview_session_id UUID,
  message_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    im.interview_session_id,
    COUNT(*)::BIGINT AS message_count
  FROM interview_messages im
  WHERE im.interview_session_id = ANY(session_ids)
  GROUP BY im.interview_session_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Add is_public_by_admin column to interview_report table
-- This allows admin to control which reports are visible to users

ALTER TABLE interview_report
ADD COLUMN is_public_by_admin BOOLEAN NOT NULL DEFAULT false;

-- Add index for filtering public reports
CREATE INDEX idx_interview_report_is_public_by_admin ON interview_report(is_public_by_admin);

-- Add comment for documentation
COMMENT ON COLUMN interview_report.is_public_by_admin IS '管理者によるレポートの公開状態（true: 公開, false: 非公開）';

-- interview_sessionsテーブルにarchived_atカラムを追加
-- セッションをアーカイブ（やり直し）した場合に設定される
ALTER TABLE interview_sessions ADD COLUMN archived_at TIMESTAMPTZ;

-- interview_report テーブルに scores カラムを追加
ALTER TABLE interview_report ADD COLUMN scores JSONB;

-- コメント追加
COMMENT ON COLUMN interview_report.scores IS 'インタビューの評価スコア（total, clarity, specificity, impact, constructiveness, reasoning）';
-- Add is_public_by_user column to interview_sessions table
ALTER TABLE interview_sessions
ADD COLUMN is_public_by_user BOOLEAN NOT NULL DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN interview_sessions.is_public_by_user IS 'Whether the user has consented to making their interview public';
-- interview_report テーブルに total_score Generated Column を追加
-- scores JSONB から total を抽出し、INTEGER として保存
-- scores が null または total が存在しない場合は null になる

ALTER TABLE interview_report
ADD COLUMN total_score INTEGER GENERATED ALWAYS AS (
  CASE
    WHEN scores IS NOT NULL
      AND scores->>'total' IS NOT NULL
      AND scores->>'total' ~ '^\d+$'
    THEN (scores->>'total')::integer
    ELSE NULL
  END
) STORED;

-- ソート用のインデックスを追加（降順、NULLは最後）
CREATE INDEX idx_interview_report_total_score ON interview_report(total_score DESC NULLS LAST);

-- コメント追加
COMMENT ON COLUMN interview_report.total_score IS '総合スコア（0-100）- scoresから自動生成されるGenerated Column';
-- Add is_active flag to diet_sessions table
-- This flag determines which session's bills are displayed on the top page
-- Only one session should be active at a time (enforced by the RPC function)

ALTER TABLE diet_sessions
ADD COLUMN is_active boolean NOT NULL DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN diet_sessions.is_active IS 'Whether this session is the active one displayed on the top page. Only one session can be active at a time.';

-- Atomic function to set a diet session as active
-- This ensures only one session can be active at a time, avoiding race conditions
-- SECURITY DEFINER allows this function to bypass RLS restrictions
CREATE OR REPLACE FUNCTION set_active_diet_session(target_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Single atomic UPDATE: set is_active based on whether id matches target
  UPDATE diet_sessions
  SET is_active = (id = target_session_id)
  -- WHERE clause required by Supabase on UPDATE queries
  -- https://supabase.com/docs/reference/javascript/update
  WHERE id IS NOT NULL;
END;
$$;
-- Create ENUM type for interview_report.role
CREATE TYPE interview_report_role_enum AS ENUM (
  'subject_expert',        -- 専門家
  'work_related',          -- 仕事関係者
  'daily_life_affected',   -- 生活影響を受ける人
  'general_citizen'        -- 一般市民
);

-- Alter the interview_report table to use the new ENUM type
-- First, we need to update existing data to match one of the ENUM values
-- Since existing data uses Japanese text like "当事者A", we'll map them to general_citizen as a safe default
UPDATE interview_report
SET role = 'general_citizen'
WHERE role IS NOT NULL;

-- Now alter the column to use the ENUM type
ALTER TABLE interview_report
ALTER COLUMN role TYPE interview_report_role_enum
USING CASE
  WHEN role IS NULL THEN NULL
  ELSE role::interview_report_role_enum
END;

-- Add comment for documentation
COMMENT ON TYPE interview_report_role_enum IS 'インタビュー対象者の役割・属性を表すENUM型';
COMMENT ON COLUMN interview_report.role IS 'AIが推論したユーザーの役割・属性（ENUM型）';
-- Add role_title column to interview_report table
-- role_title is a short summary (10 characters or less) derived from role_description
ALTER TABLE interview_report
ADD COLUMN role_title TEXT;

-- Add comment explaining the column purpose
COMMENT ON COLUMN interview_report.role_title IS 'A short title (10 characters or less) summarizing the user role, e.g., "物流業者", "主婦"';
-- Allow multiple interview configs per bill with required name field
-- Only one config per bill can have status='public'

-- Step 1: Add name column with default value for existing records
ALTER TABLE interview_configs
ADD COLUMN name TEXT NOT NULL DEFAULT 'デフォルト設定';

-- Step 2: Remove the default constraint after migration
ALTER TABLE interview_configs
ALTER COLUMN name DROP DEFAULT;

-- Step 3: Drop the UNIQUE constraint on bill_id
-- First, find and drop the unique constraint
ALTER TABLE interview_configs DROP CONSTRAINT IF EXISTS interview_configs_bill_id_key;

-- Step 4: Create partial unique index to ensure only one public config per bill
CREATE UNIQUE INDEX idx_interview_configs_bill_public
ON interview_configs(bill_id)
WHERE status = 'public';

-- Step 5: Create index for querying configs by bill_id
CREATE INDEX idx_interview_configs_bill_id ON interview_configs(bill_id);

-- Update comments
COMMENT ON COLUMN interview_configs.name IS '設定名（識別用）';
COMMENT ON COLUMN interview_configs.bill_id IS '対象議案ID（複数設定可、ただしpublicは1つのみ）';
-- Add interview mode to interview_configs
-- Modes: loop (逐次深掘り) and bulk (一括深掘り)

-- Step 1: Create enum type for interview mode
CREATE TYPE interview_mode_enum AS ENUM ('loop', 'bulk');

-- Step 2: Add mode column with default value 'loop'
ALTER TABLE interview_configs
ADD COLUMN mode interview_mode_enum NOT NULL DEFAULT 'loop';

-- Step 3: Add comment for documentation
COMMENT ON COLUMN interview_configs.mode IS 'インタビューモード: loop（逐次深掘り）または bulk（一括深掘り）';
-- admin管理画面用: admin権限を持つユーザー一覧をDBレイヤーでフィルタして返す
CREATE OR REPLACE FUNCTION public.get_admin_users()
RETURNS TABLE (
  id uuid,
  email text,
  created_at timestamptz,
  last_sign_in_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT u.id, u.email, u.created_at, u.last_sign_in_at
  FROM auth.users u
  WHERE u.raw_app_meta_data->'roles' ? 'admin'
  ORDER BY u.created_at DESC;
$$;

-- service_role のみ実行可能にし、anon/authenticated からのアクセスを遮断
REVOKE EXECUTE ON FUNCTION public.get_admin_users() FROM public;
GRANT EXECUTE ON FUNCTION public.get_admin_users() TO service_role;
-- get_admin_users() の権限修正
-- Supabase の ALTER DEFAULT PRIVILEGES により anon/authenticated にも
-- EXECUTE が自動付与されるため、REVOKE FROM public だけでは不十分。
-- anon/authenticated からも明示的に REVOKE する。
REVOKE EXECUTE ON FUNCTION public.get_admin_users() FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_admin_users() FROM authenticated;
-- インタビュー設定にチャット用AIモデル選択カラムを追加
-- Vercel AI Gateway形式のモデルID（例: "openai/gpt-4o-mini"）を格納
-- NULLの場合はデフォルトモデル（gpt-4o-mini）を使用

ALTER TABLE interview_configs
ADD COLUMN chat_model TEXT DEFAULT NULL;
-- interview_questions テーブルの instruction カラムを follow_up_guide にリネーム
ALTER TABLE interview_questions RENAME COLUMN instruction TO follow_up_guide;

-- カラムコメントを更新
COMMENT ON COLUMN interview_questions.follow_up_guide IS '回答後のフォローアップ指針（深掘り方法など）';
-- interview_configs テーブルに目安時間（分）カラムを追加
-- NULL の場合はタイムマネジメントしない
ALTER TABLE interview_configs ADD COLUMN estimated_duration INTEGER;
-- interview_sessions テーブルに rating カラムを追加（星1〜5、nullable）
alter table interview_sessions
  add column rating smallint check (rating >= 1 and rating <= 5);
-- 有識者リスト登録情報を管理するテーブル
CREATE TABLE expert_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_session_id UUID NOT NULL REFERENCES interview_sessions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  affiliation TEXT NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- セッションごとに1件のみ登録可能
CREATE UNIQUE INDEX idx_expert_registrations_session_id ON expert_registrations(interview_session_id);

-- メールアドレスの一意性を保証
CREATE UNIQUE INDEX idx_expert_registrations_email ON expert_registrations(email);

-- updated_atトリガー
CREATE TRIGGER update_expert_registrations_updated_at
  BEFORE UPDATE ON expert_registrations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE expert_registrations ENABLE ROW LEVEL SECURITY;

-- カラムコメント
COMMENT ON TABLE expert_registrations IS '有識者リスト登録情報を管理するテーブル';
COMMENT ON COLUMN expert_registrations.interview_session_id IS '登録元のインタビューセッションID';
COMMENT ON COLUMN expert_registrations.name IS '有識者の氏名';
COMMENT ON COLUMN expert_registrations.affiliation IS '所属・肩書';
COMMENT ON COLUMN expert_registrations.email IS 'メールアドレス';
-- expert_registrations を interview_session_id ベースから user_id ベースに変更

-- 既存のインデックスを削除
DROP INDEX IF EXISTS idx_expert_registrations_session_id;

-- user_id カラムを nullable で追加
ALTER TABLE expert_registrations ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 既存データがある場合、interview_sessions から user_id をバックフィル
UPDATE expert_registrations er
SET user_id = s.user_id
FROM interview_sessions s
WHERE er.interview_session_id = s.id;

-- バックフィル後に NOT NULL 制約を付与
ALTER TABLE expert_registrations ALTER COLUMN user_id SET NOT NULL;

-- interview_session_id カラムを削除
ALTER TABLE expert_registrations DROP COLUMN interview_session_id;

-- ユーザーごとに1件のみ登録可能
CREATE UNIQUE INDEX idx_expert_registrations_user_id ON expert_registrations(user_id);

-- カラムコメント更新
COMMENT ON COLUMN expert_registrations.user_id IS '登録したユーザーのID';
-- billsテーブルにstatusのソート順を表すgenerated columnを追加
-- enacted(成立)を先頭に、審議進行度順で並べるための整数カラム
ALTER TABLE bills ADD COLUMN status_order INT GENERATED ALWAYS AS (
  CASE status
    WHEN 'enacted'              THEN 0
    WHEN 'rejected'             THEN 1
    WHEN 'in_receiving_house'   THEN 2
    WHEN 'in_originating_house' THEN 3
    WHEN 'introduced'           THEN 4
    WHEN 'preparing'            THEN 5
  END
) STORED;

CREATE INDEX idx_bills_status_order ON bills(status_order);
-- Move is_public_by_user from interview_sessions to interview_report
-- This column belongs on the report as it represents user consent for report publication

-- Step 1: Add is_public_by_user to interview_report
ALTER TABLE interview_report
ADD COLUMN is_public_by_user BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN interview_report.is_public_by_user IS 'Whether the user has consented to making their interview report public';

-- Step 2: Migrate existing data from interview_sessions to interview_report
UPDATE interview_report
SET is_public_by_user = interview_sessions.is_public_by_user
FROM interview_sessions
WHERE interview_report.interview_session_id = interview_sessions.id;

-- Step 3: Drop the column from interview_sessions
ALTER TABLE interview_sessions
DROP COLUMN is_public_by_user;
-- レポートへのリアクション機能
-- ユーザーは1つのレポートに対して1つのリアクション（helpful or hmm）のみ可能
create table report_reactions (
  id uuid primary key default gen_random_uuid(),
  interview_report_id uuid not null references interview_report(id) on delete cascade,
  user_id uuid not null,
  reaction_type text not null check (reaction_type in ('helpful', 'hmm')),
  created_at timestamptz not null default now(),
  unique(interview_report_id, user_id)
);

-- RLS有効化（ポリシーなし = デフォルト全拒否、アクセスはAdmin Client経由のみ）
alter table report_reactions enable row level security;

-- パフォーマンス用インデックス
create index idx_report_reactions_report_id on report_reactions(interview_report_id);
create index idx_report_reactions_user_id on report_reactions(user_id);
-- 複数レポートのリアクション数をDB側で集約して返すRPC関数
create or replace function count_reactions_by_report_ids(report_ids uuid[])
returns table (
  interview_report_id uuid,
  reaction_type text,
  cnt bigint
)
language sql
stable
as $$
  select
    r.interview_report_id,
    r.reaction_type,
    count(*) as cnt
  from report_reactions r
  where r.interview_report_id = any(report_ids)
  group by r.interview_report_id, r.reaction_type;
$$;
-- トピック解析バージョン管理テーブル
CREATE TABLE topic_analysis_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','running','completed','failed')),
  summary_md TEXT,
  intermediate_results JSONB,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(bill_id, version)
);

COMMENT ON TABLE topic_analysis_versions IS 'トピック解析のバージョン管理';
COMMENT ON COLUMN topic_analysis_versions.bill_id IS '対象議案ID';
COMMENT ON COLUMN topic_analysis_versions.version IS 'バージョン番号（議案ごとにインクリメント）';
COMMENT ON COLUMN topic_analysis_versions.status IS '解析ステータス: pending, running, completed, failed';
COMMENT ON COLUMN topic_analysis_versions.summary_md IS '全体サマリ（markdown形式）';
COMMENT ON COLUMN topic_analysis_versions.intermediate_results IS '中間結果（デバッグ・参照用）';
COMMENT ON COLUMN topic_analysis_versions.error_message IS 'エラー時のメッセージ';

-- トピックテーブル
CREATE TABLE topic_analysis_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES topic_analysis_versions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description_md TEXT NOT NULL,
  representative_opinions JSONB NOT NULL DEFAULT '[]',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE topic_analysis_topics IS 'トピック解析で抽出されたトピック';
COMMENT ON COLUMN topic_analysis_topics.version_id IS '所属バージョンID';
COMMENT ON COLUMN topic_analysis_topics.name IS 'トピック名';
COMMENT ON COLUMN topic_analysis_topics.description_md IS 'トピックの説明文（markdown形式）';
COMMENT ON COLUMN topic_analysis_topics.representative_opinions IS '代表的な意見（JSON配列、最大5件）';
COMMENT ON COLUMN topic_analysis_topics.sort_order IS '表示順';

-- 分類テーブル（opinion → topic の多対多）
CREATE TABLE topic_analysis_classifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES topic_analysis_versions(id) ON DELETE CASCADE,
  interview_report_id UUID NOT NULL REFERENCES interview_report(id) ON DELETE CASCADE,
  topic_id UUID NOT NULL REFERENCES topic_analysis_topics(id) ON DELETE CASCADE,
  opinion_index INTEGER NOT NULL,
  UNIQUE(version_id, interview_report_id, topic_id, opinion_index)
);

COMMENT ON TABLE topic_analysis_classifications IS '意見とトピックの分類（多対多）';
COMMENT ON COLUMN topic_analysis_classifications.version_id IS '所属バージョンID';
COMMENT ON COLUMN topic_analysis_classifications.interview_report_id IS 'インタビューレポートID';
COMMENT ON COLUMN topic_analysis_classifications.topic_id IS 'トピックID';
COMMENT ON COLUMN topic_analysis_classifications.opinion_index IS 'レポート内の意見インデックス';

-- インデックス
CREATE INDEX idx_topic_analysis_versions_bill_id ON topic_analysis_versions(bill_id);
CREATE INDEX idx_topic_analysis_topics_version_id ON topic_analysis_topics(version_id);
CREATE INDEX idx_topic_analysis_classifications_version_id ON topic_analysis_classifications(version_id);
CREATE INDEX idx_topic_analysis_classifications_topic_id ON topic_analysis_classifications(topic_id);

-- RLS
ALTER TABLE topic_analysis_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_analysis_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_analysis_classifications ENABLE ROW LEVEL SECURITY;

-- service_role は RLS をバイパスするため、明示的なポリシーは不要

-- updated_at 自動更新トリガー
CREATE TRIGGER set_topic_analysis_versions_updated_at
  BEFORE UPDATE ON topic_analysis_versions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
ALTER TABLE topic_analysis_versions
  ADD COLUMN current_step TEXT,
  ADD COLUMN started_at TIMESTAMPTZ,
  ADD COLUMN completed_at TIMESTAMPTZ;
-- フェーズ間データ受け渡し用カラム
ALTER TABLE topic_analysis_versions ADD COLUMN phase_data JSONB;
-- 不要な全アクセスポリシーを削除
-- service_role は RLS をバイパスするため、明示的なポリシーは不要
-- 他テーブル（bills, interview_configs 等）と同じパターンに統一

DROP POLICY IF EXISTS "Service role full access" ON topic_analysis_versions;
DROP POLICY IF EXISTS "Service role full access" ON topic_analysis_topics;
DROP POLICY IF EXISTS "Service role full access" ON topic_analysis_classifications;
-- billsテーブルにpublish_statusのソート順を表すgenerated columnを追加
-- 下書き(draft)→Coming Soon(coming_soon)→公開(published) の順
ALTER TABLE bills ADD COLUMN publish_status_order INT GENERATED ALWAYS AS (
  CASE publish_status
    WHEN 'draft'       THEN 0
    WHEN 'coming_soon' THEN 1
    WHEN 'published'   THEN 2
  END
) STORED;

ALTER TABLE bills ENABLE ROW LEVEL SECURITY;

CREATE INDEX idx_bills_publish_status_order ON bills(publish_status_order);
-- Fetch interview sessions ordered by message count with pagination
-- Used for admin report list table sorting by message count
CREATE OR REPLACE FUNCTION find_sessions_ordered_by_message_count(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*)::BIGINT AS cnt
    FROM interview_messages im
    INNER JOIN interview_sessions iss
      ON iss.id = im.interview_session_id
    WHERE iss.interview_config_id = p_config_id
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(mc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(mc.cnt, 0) END DESC,
    s.started_at DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- Fetch interview sessions ordered by total_score with pagination
-- Used for admin report list table sorting by score
CREATE OR REPLACE FUNCTION find_sessions_ordered_by_total_score(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
  ORDER BY
    CASE WHEN p_ascending THEN r.total_score END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.total_score END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- Compute aggregate interview statistics for a given interview config
-- Used for admin interview report list page statistics display
CREATE OR REPLACE FUNCTION get_interview_statistics(p_config_id UUID)
RETURNS TABLE (
  total_sessions BIGINT,
  completed_sessions BIGINT,
  avg_rating NUMERIC,
  stance_for_count BIGINT,
  stance_against_count BIGINT,
  stance_neutral_count BIGINT,
  avg_total_score NUMERIC,
  role_subject_expert_count BIGINT,
  role_work_related_count BIGINT,
  role_daily_life_affected_count BIGINT,
  role_general_citizen_count BIGINT,
  avg_message_count NUMERIC,
  avg_duration_seconds NUMERIC,
  public_by_user_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    -- Session counts
    COUNT(s.id) AS total_sessions,
    COUNT(s.completed_at) AS completed_sessions,

    -- Average satisfaction rating (from completed sessions with rating)
    ROUND(AVG(s.rating)::NUMERIC, 2) AS avg_rating,

    -- Stance distribution (for/against/neutral only)
    COUNT(CASE WHEN r.stance = 'for' THEN 1 END) AS stance_for_count,
    COUNT(CASE WHEN r.stance = 'against' THEN 1 END) AS stance_against_count,
    COUNT(CASE WHEN r.stance = 'neutral' THEN 1 END) AS stance_neutral_count,

    -- Average total score
    ROUND(AVG(r.total_score)::NUMERIC, 1) AS avg_total_score,

    -- Role distribution
    COUNT(CASE WHEN r.role = 'subject_expert' THEN 1 END) AS role_subject_expert_count,
    COUNT(CASE WHEN r.role = 'work_related' THEN 1 END) AS role_work_related_count,
    COUNT(CASE WHEN r.role = 'daily_life_affected' THEN 1 END) AS role_daily_life_affected_count,
    COUNT(CASE WHEN r.role = 'general_citizen' THEN 1 END) AS role_general_citizen_count,

    -- Average message count per session
    ROUND(AVG(COALESCE(mc.message_count, 0))::NUMERIC, 1) AS avg_message_count,

    -- Average duration in seconds (completed sessions only)
    ROUND(AVG(
      CASE WHEN s.completed_at IS NOT NULL
        THEN EXTRACT(EPOCH FROM (s.completed_at - s.started_at))
      END
    )::NUMERIC, 0) AS avg_duration_seconds,

    -- Public by user count
    COUNT(CASE WHEN r.is_public_by_user = TRUE THEN 1 END) AS public_by_user_count

  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*) AS message_count
    FROM interview_messages im
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id;
END;
$$ LANGUAGE plpgsql STABLE;
-- Restrict get_interview_statistics execution to service_role only
-- This function is admin-only and should not be callable by anon/authenticated
REVOKE EXECUTE ON FUNCTION public.get_interview_statistics(UUID) FROM public;
REVOKE EXECUTE ON FUNCTION public.get_interview_statistics(UUID) FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_interview_statistics(UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.get_interview_statistics(UUID) TO service_role;
-- Change average duration to median duration in interview statistics
-- DROP is required because RETURNS TABLE column rename is not allowed by CREATE OR REPLACE
DROP FUNCTION IF EXISTS get_interview_statistics(UUID);
CREATE FUNCTION get_interview_statistics(p_config_id UUID)
RETURNS TABLE (
  total_sessions BIGINT,
  completed_sessions BIGINT,
  avg_rating NUMERIC,
  stance_for_count BIGINT,
  stance_against_count BIGINT,
  stance_neutral_count BIGINT,
  avg_total_score NUMERIC,
  role_subject_expert_count BIGINT,
  role_work_related_count BIGINT,
  role_daily_life_affected_count BIGINT,
  role_general_citizen_count BIGINT,
  avg_message_count NUMERIC,
  median_duration_seconds NUMERIC,
  public_by_user_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    -- Session counts
    COUNT(s.id) AS total_sessions,
    COUNT(s.completed_at) AS completed_sessions,

    -- Average satisfaction rating (from completed sessions with rating)
    ROUND(AVG(s.rating)::NUMERIC, 2) AS avg_rating,

    -- Stance distribution (for/against/neutral only)
    COUNT(CASE WHEN r.stance = 'for' THEN 1 END) AS stance_for_count,
    COUNT(CASE WHEN r.stance = 'against' THEN 1 END) AS stance_against_count,
    COUNT(CASE WHEN r.stance = 'neutral' THEN 1 END) AS stance_neutral_count,

    -- Average total score
    ROUND(AVG(r.total_score)::NUMERIC, 1) AS avg_total_score,

    -- Role distribution
    COUNT(CASE WHEN r.role = 'subject_expert' THEN 1 END) AS role_subject_expert_count,
    COUNT(CASE WHEN r.role = 'work_related' THEN 1 END) AS role_work_related_count,
    COUNT(CASE WHEN r.role = 'daily_life_affected' THEN 1 END) AS role_daily_life_affected_count,
    COUNT(CASE WHEN r.role = 'general_citizen' THEN 1 END) AS role_general_citizen_count,

    -- Average message count per session
    ROUND(AVG(COALESCE(mc.message_count, 0))::NUMERIC, 1) AS avg_message_count,

    -- Median duration in seconds (completed sessions only)
    ROUND(
      (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY EXTRACT(EPOCH FROM (sub.completed_at - sub.started_at))
      )
      FROM interview_sessions sub
      WHERE sub.interview_config_id = p_config_id
        AND sub.completed_at IS NOT NULL
      )::NUMERIC, 0
    ) AS median_duration_seconds,

    -- Public by user count
    COUNT(CASE WHEN r.is_public_by_user = TRUE THEN 1 END) AS public_by_user_count

  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*) AS message_count
    FROM interview_messages im
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id;
END;
$$ LANGUAGE plpgsql STABLE;
-- Drop old signatures (different arg count = different overload in PostgreSQL)
DROP FUNCTION IF EXISTS find_sessions_ordered_by_message_count(UUID, BOOLEAN, INT, INT);
DROP FUNCTION IF EXISTS find_sessions_ordered_by_total_score(UUID, BOOLEAN, INT, INT);

-- Recreate with filter parameters
CREATE FUNCTION find_sessions_ordered_by_message_count(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*)::BIGINT AS cnt
    FROM interview_messages im
    INNER JOIN interview_sessions iss
      ON iss.id = im.interview_session_id
    WHERE iss.interview_config_id = p_config_id
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(mc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(mc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION find_sessions_ordered_by_total_score(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.total_score END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.total_score END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- Fetch interview sessions ordered by helpful reaction count with pagination
-- Used for admin report list table sorting by helpful reaction count
CREATE FUNCTION find_sessions_ordered_by_helpful_count(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*)::BIGINT AS cnt
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) hc ON hc.interview_report_id = r.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(hc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(hc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- Rename "scores" concept to "content_richness" (情報の充実度)
-- The JSONB internal keys (total, clarity, specificity, impact, constructiveness, reasoning) remain unchanged.
-- Only column names, generated columns, RPC function names, and return column names are renamed.

-- 1. Drop the generated column (depends on "scores" column)
ALTER TABLE interview_report DROP COLUMN total_score;

-- 2. Rename JSONB column
ALTER TABLE interview_report RENAME COLUMN scores TO content_richness;

-- 3. Recreate generated column with new name
ALTER TABLE interview_report
ADD COLUMN total_content_richness INTEGER GENERATED ALWAYS AS (
  CASE
    WHEN content_richness IS NOT NULL
      AND content_richness->>'total' IS NOT NULL
      AND content_richness->>'total' ~ '^\d+$'
    THEN (content_richness->>'total')::integer
    ELSE NULL
  END
) STORED;

CREATE INDEX idx_interview_report_total_content_richness
  ON interview_report(total_content_richness DESC NULLS LAST);

COMMENT ON COLUMN interview_report.content_richness IS 'インタビューの情報充実度評価（total, clarity, specificity, impact, constructiveness, reasoning）';
COMMENT ON COLUMN interview_report.total_content_richness IS '総合的な情報充実度（0-100）- content_richnessから自動生成されるGenerated Column';

-- 4. Rename find_sessions_ordered_by_total_score → find_sessions_ordered_by_total_content_richness
DROP FUNCTION IF EXISTS find_sessions_ordered_by_total_score(UUID, BOOLEAN, INT, INT, TEXT, TEXT, TEXT, TEXT);

CREATE FUNCTION find_sessions_ordered_by_total_content_richness(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.total_content_richness END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.total_content_richness END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- 5. Rename avg_total_score → avg_total_content_richness in get_interview_statistics
DROP FUNCTION IF EXISTS get_interview_statistics(UUID);

CREATE FUNCTION get_interview_statistics(p_config_id UUID)
RETURNS TABLE (
  total_sessions BIGINT,
  completed_sessions BIGINT,
  avg_rating NUMERIC,
  stance_for_count BIGINT,
  stance_against_count BIGINT,
  stance_neutral_count BIGINT,
  avg_total_content_richness NUMERIC,
  role_subject_expert_count BIGINT,
  role_work_related_count BIGINT,
  role_daily_life_affected_count BIGINT,
  role_general_citizen_count BIGINT,
  avg_message_count NUMERIC,
  median_duration_seconds NUMERIC,
  public_by_user_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(s.id) AS total_sessions,
    COUNT(s.completed_at) AS completed_sessions,
    ROUND(AVG(s.rating)::NUMERIC, 2) AS avg_rating,
    COUNT(CASE WHEN r.stance = 'for' THEN 1 END) AS stance_for_count,
    COUNT(CASE WHEN r.stance = 'against' THEN 1 END) AS stance_against_count,
    COUNT(CASE WHEN r.stance = 'neutral' THEN 1 END) AS stance_neutral_count,
    ROUND(AVG(r.total_content_richness)::NUMERIC, 1) AS avg_total_content_richness,
    COUNT(CASE WHEN r.role = 'subject_expert' THEN 1 END) AS role_subject_expert_count,
    COUNT(CASE WHEN r.role = 'work_related' THEN 1 END) AS role_work_related_count,
    COUNT(CASE WHEN r.role = 'daily_life_affected' THEN 1 END) AS role_daily_life_affected_count,
    COUNT(CASE WHEN r.role = 'general_citizen' THEN 1 END) AS role_general_citizen_count,
    ROUND(AVG(COALESCE(mc.message_count, 0))::NUMERIC, 1) AS avg_message_count,
    ROUND(
      (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY EXTRACT(EPOCH FROM (sub.completed_at - sub.started_at))
      )
      FROM interview_sessions sub
      WHERE sub.interview_config_id = p_config_id
        AND sub.completed_at IS NOT NULL
      )::NUMERIC, 0
    ) AS median_duration_seconds,
    COUNT(CASE WHEN r.is_public_by_user = TRUE THEN 1 END) AS public_by_user_count
  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*) AS message_count
    FROM interview_messages im
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id;
END;
$$ LANGUAGE plpgsql STABLE;
-- モデレーションステータスのENUM型を作成
create type moderation_status_enum as enum ('ok', 'warning', 'ng');

-- interview_report テーブルにモデレーション関連カラムを追加
alter table interview_report
  add column moderation_score integer,
  add column moderation_status moderation_status_enum
    generated always as (
      case
        when moderation_score is null then null
        when moderation_score >= 70 then 'ng'::moderation_status_enum
        when moderation_score >= 30 then 'warning'::moderation_status_enum
        else 'ok'::moderation_status_enum
      end
    ) stored;

-- モデレーションスコアの制約 (0-100)
alter table interview_report
  add constraint chk_moderation_score_range
  check (moderation_score is null or (moderation_score >= 0 and moderation_score <= 100));

-- モデレーションステータスでのフィルタリング用インデックス
create index idx_interview_report_moderation_status on interview_report(moderation_status);

-- カラムコメント
comment on column interview_report.moderation_score is 'モデレーションスコア（0-100）: 0が最も適切、100が最も不適切';
comment on column interview_report.moderation_status is 'モデレーションステータス（generated column）: ok=問題なし, warning=要注意, ng=不適切';
-- 公開レポートをhelpfulリアクション数×5 + total_content_richnessの重み付きスコア降順で取得するRPC関数
-- 議案詳細ページ・ご意見一覧ページのソートに使用
CREATE OR REPLACE FUNCTION find_public_reports_by_bill_id_ordered_by_reactions(
  p_bill_id UUID,
  p_limit INT DEFAULT 1000
)
RETURNS TABLE (
  id UUID,
  stance stance_type_enum,
  role interview_report_role_enum,
  role_title TEXT,
  summary TEXT,
  total_content_richness INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.id,
    ir.stance,
    ir.role,
    ir.role_title,
    ir.summary,
    ir.total_content_richness,
    ir.created_at
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*) AS helpful_count
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) rc ON rc.interview_report_id = ir.id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
  ORDER BY (COALESCE(rc.helpful_count, 0) * 5 + COALESCE(ir.total_content_richness, 0)) DESC, ir.created_at DESC, ir.id DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- Add archived status filter support to sort RPC functions
-- archived = completed_at IS NULL AND archived_at IS NOT NULL

-- 1. find_sessions_ordered_by_message_count
DROP FUNCTION IF EXISTS find_sessions_ordered_by_message_count(UUID, BOOLEAN, INT, INT, TEXT, TEXT, TEXT, TEXT);

CREATE FUNCTION find_sessions_ordered_by_message_count(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN (
    SELECT im.interview_session_id, COUNT(*)::BIGINT AS cnt
    FROM interview_messages im
    INNER JOIN interview_sessions iss
      ON iss.id = im.interview_session_id
    WHERE iss.interview_config_id = p_config_id
    GROUP BY im.interview_session_id
  ) mc ON mc.interview_session_id = s.id
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(mc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(mc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- 2. find_sessions_ordered_by_total_content_richness
DROP FUNCTION IF EXISTS find_sessions_ordered_by_total_content_richness(UUID, BOOLEAN, INT, INT, TEXT, TEXT, TEXT, TEXT);

CREATE FUNCTION find_sessions_ordered_by_total_content_richness(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.total_content_richness END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.total_content_richness END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- 3. find_sessions_ordered_by_helpful_count
DROP FUNCTION IF EXISTS find_sessions_ordered_by_helpful_count(UUID, BOOLEAN, INT, INT, TEXT, TEXT, TEXT, TEXT);

CREATE FUNCTION find_sessions_ordered_by_helpful_count(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r ON r.interview_session_id = s.id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*)::BIGINT AS cnt
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) hc ON hc.interview_report_id = r.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN COALESCE(hc.cnt, 0) END ASC,
    CASE WHEN NOT p_ascending THEN COALESCE(hc.cnt, 0) END DESC,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- 旧シグネチャの関数をドロップ（新しいパラメータ追加のため）
DROP FUNCTION IF EXISTS find_public_reports_by_bill_id_ordered_by_reactions(UUID, INT);

-- 公開レポート取得RPC関数にページネーション（offset）とスタンスフィルターを追加
CREATE OR REPLACE FUNCTION find_public_reports_by_bill_id_ordered_by_reactions(
  p_bill_id UUID,
  p_limit INT DEFAULT 1000,
  p_offset INT DEFAULT 0,
  p_stance TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  stance stance_type_enum,
  role interview_report_role_enum,
  role_title TEXT,
  summary TEXT,
  total_content_richness INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.id,
    ir.stance,
    ir.role,
    ir.role_title,
    ir.summary,
    ir.total_content_richness,
    ir.created_at
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*) AS helpful_count
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) rc ON rc.interview_report_id = ir.id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
    AND (p_stance IS NULL OR ir.stance::TEXT = p_stance)
  ORDER BY (COALESCE(rc.helpful_count, 0) * 5 + COALESCE(ir.total_content_richness, 0)) DESC, ir.created_at DESC, ir.id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- スタンスごとの公開レポート件数を取得するRPC関数
CREATE OR REPLACE FUNCTION count_public_reports_by_stance(
  p_bill_id UUID
)
RETURNS TABLE (
  stance TEXT,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.stance::TEXT AS stance,
    COUNT(*) AS count
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
  GROUP BY ir.stance;
END;
$$ LANGUAGE plpgsql STABLE;
-- フィードバックタグ種別のENUM型を作成
create type interview_feedback_tag_enum as enum (
  'irrelevant_questions',
  'not_aligned',
  'misunderstood',
  'too_many_questions',
  'other'
);

-- 低評価時のフィードバックタグテーブルを作成
create table interview_rating_feedbacks (
  id uuid primary key default gen_random_uuid(),
  interview_session_id uuid not null
    references interview_sessions(id) on delete cascade,
  tag interview_feedback_tag_enum not null,
  created_at timestamptz not null default now(),

  -- 同一セッションに同じタグの重複を防止
  unique (interview_session_id, tag)
);

alter table interview_rating_feedbacks enable row level security;

-- 集計クエリ用インデックス
create index idx_interview_rating_feedbacks_session
  on interview_rating_feedbacks(interview_session_id);

create index idx_interview_rating_feedbacks_tag
  on interview_rating_feedbacks(tag);

comment on table interview_rating_feedbacks is '低評価（3以下）時のフィードバックタグ';
comment on column interview_rating_feedbacks.tag is 'フィードバックタグ種別';
-- get_interview_statistics にフィードバックタグ集計を追加
drop function if exists get_interview_statistics(uuid);

create function get_interview_statistics(p_config_id uuid)
returns table (
  total_sessions bigint,
  completed_sessions bigint,
  avg_rating numeric,
  stance_for_count bigint,
  stance_against_count bigint,
  stance_neutral_count bigint,
  avg_total_content_richness numeric,
  role_subject_expert_count bigint,
  role_work_related_count bigint,
  role_daily_life_affected_count bigint,
  role_general_citizen_count bigint,
  avg_message_count numeric,
  median_duration_seconds numeric,
  public_by_user_count bigint,
  feedback_irrelevant_questions bigint,
  feedback_not_aligned bigint,
  feedback_misunderstood bigint,
  feedback_too_many_questions bigint,
  feedback_other bigint
) as $$
begin
  return query
  select
    count(s.id) as total_sessions,
    count(s.completed_at) as completed_sessions,
    round(avg(s.rating)::numeric, 2) as avg_rating,
    count(case when r.stance = 'for' then 1 end) as stance_for_count,
    count(case when r.stance = 'against' then 1 end) as stance_against_count,
    count(case when r.stance = 'neutral' then 1 end) as stance_neutral_count,
    round(avg(r.total_content_richness)::numeric, 1) as avg_total_content_richness,
    count(case when r.role = 'subject_expert' then 1 end) as role_subject_expert_count,
    count(case when r.role = 'work_related' then 1 end) as role_work_related_count,
    count(case when r.role = 'daily_life_affected' then 1 end) as role_daily_life_affected_count,
    count(case when r.role = 'general_citizen' then 1 end) as role_general_citizen_count,
    round(avg(coalesce(mc.message_count, 0))::numeric, 1) as avg_message_count,
    round(
      (select percentile_cont(0.5) within group (
        order by extract(epoch from (sub.completed_at - sub.started_at))
      )
      from interview_sessions sub
      where sub.interview_config_id = p_config_id
        and sub.completed_at is not null
      )::numeric, 0
    ) as median_duration_seconds,
    count(case when r.is_public_by_user = true then 1 end) as public_by_user_count,
    -- フィードバックタグ集計（単一サブクエリで全タグを集計）
    coalesce(max(fc.feedback_irrelevant_questions), 0) as feedback_irrelevant_questions,
    coalesce(max(fc.feedback_not_aligned), 0) as feedback_not_aligned,
    coalesce(max(fc.feedback_misunderstood), 0) as feedback_misunderstood,
    coalesce(max(fc.feedback_too_many_questions), 0) as feedback_too_many_questions,
    coalesce(max(fc.feedback_other), 0) as feedback_other
  from interview_sessions s
  left join interview_report r on r.interview_session_id = s.id
  left join (
    select im.interview_session_id, count(*) as message_count
    from interview_messages im
    group by im.interview_session_id
  ) mc on mc.interview_session_id = s.id
  left join (
    select
      count(*) filter (where f.tag = 'irrelevant_questions') as feedback_irrelevant_questions,
      count(*) filter (where f.tag = 'not_aligned') as feedback_not_aligned,
      count(*) filter (where f.tag = 'misunderstood') as feedback_misunderstood,
      count(*) filter (where f.tag = 'too_many_questions') as feedback_too_many_questions,
      count(*) filter (where f.tag = 'other') as feedback_other
    from interview_rating_feedbacks f
    join interview_sessions fs on fs.id = f.interview_session_id
    where fs.interview_config_id = p_config_id
  ) fc on true
  where s.interview_config_id = p_config_id;
end;
$$ language plpgsql stable;
create or replace function public.sum_chat_usage_cost(
  from_iso timestamptz,
  to_iso timestamptz
)
returns numeric(12, 6)
language sql
stable
as $$
  select coalesce(sum(cost_usd), 0)
  from public.chat_usage_events
  where occurred_at >= from_iso
    and occurred_at < to_iso;
$$;

revoke execute on function public.sum_chat_usage_cost(timestamptz, timestamptz) from public;
revoke execute on function public.sum_chat_usage_cost(timestamptz, timestamptz) from anon;
revoke execute on function public.sum_chat_usage_cost(timestamptz, timestamptz) from authenticated;
grant execute on function public.sum_chat_usage_cost(timestamptz, timestamptz) to service_role;
-- interview_report テーブルにモデレーション根拠・該当カテゴリカラムを追加
alter table interview_report
  add column moderation_reasoning text,
  add column moderation_flagged_categories text[] default '{}';

-- カラムコメント
comment on column interview_report.moderation_reasoning is 'モデレーションスコアの根拠（200文字以内）';
comment on column interview_report.moderation_flagged_categories is 'モデレーションで該当した評価カテゴリ名の配列';
-- interview_report テーブルからモデレーション該当カテゴリカラムを削除
alter table interview_report
  drop column moderation_flagged_categories;
-- リアクション（helpful）の重みを5ptから1ptに変更
CREATE OR REPLACE FUNCTION find_public_reports_by_bill_id_ordered_by_reactions(
  p_bill_id UUID,
  p_limit INT DEFAULT 1000,
  p_offset INT DEFAULT 0,
  p_stance TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  stance stance_type_enum,
  role interview_report_role_enum,
  role_title TEXT,
  summary TEXT,
  total_content_richness INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.id,
    ir.stance,
    ir.role,
    ir.role_title,
    ir.summary,
    ir.total_content_richness,
    ir.created_at
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*) AS helpful_count
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) rc ON rc.interview_report_id = ir.id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
    AND (p_stance IS NULL OR ir.stance::TEXT = p_stance)
  ORDER BY (COALESCE(rc.helpful_count, 0) + COALESCE(ir.total_content_richness, 0)) DESC, ir.created_at DESC, ir.id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;
-- 公開レポート取得関数にソート順パラメータを追加（おすすめ順 / 新着順）
-- 旧シグネチャ(4引数)を削除してから新シグネチャ(5引数)で再作成
DROP FUNCTION IF EXISTS find_public_reports_by_bill_id_ordered_by_reactions(UUID, INT, INT, TEXT);

CREATE OR REPLACE FUNCTION find_public_reports_by_bill_id_ordered_by_reactions(
  p_bill_id UUID,
  p_limit INT DEFAULT 1000,
  p_offset INT DEFAULT 0,
  p_stance TEXT DEFAULT NULL,
  p_sort_order TEXT DEFAULT 'recommended'
)
RETURNS TABLE (
  id UUID,
  stance stance_type_enum,
  role interview_report_role_enum,
  role_title TEXT,
  summary TEXT,
  total_content_richness INTEGER,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ir.id,
    ir.stance,
    ir.role,
    ir.role_title,
    ir.summary,
    ir.total_content_richness,
    ir.created_at
  FROM interview_report ir
  INNER JOIN interview_sessions s ON s.id = ir.interview_session_id
  INNER JOIN interview_configs c ON c.id = s.interview_config_id
  LEFT JOIN (
    SELECT rr.interview_report_id, COUNT(*) AS helpful_count
    FROM report_reactions rr
    WHERE rr.reaction_type = 'helpful'
    GROUP BY rr.interview_report_id
  ) rc ON rc.interview_report_id = ir.id
  WHERE ir.is_public_by_admin = TRUE
    AND ir.is_public_by_user = TRUE
    AND c.bill_id = p_bill_id
    AND (p_stance IS NULL OR ir.stance::TEXT = p_stance)
  ORDER BY
    CASE WHEN p_sort_order = 'newest' THEN NULL
         ELSE (COALESCE(rc.helpful_count, 0) + COALESCE(ir.total_content_richness, 0))
    END DESC NULLS LAST,
    ir.created_at DESC,
    ir.id DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;
-- Fetch interview sessions ordered by moderation score with pagination
-- Used for admin report list table sorting by moderation score
CREATE FUNCTION find_sessions_ordered_by_moderation_score(
  p_config_id UUID,
  p_ascending BOOLEAN DEFAULT FALSE,
  p_offset INT DEFAULT 0,
  p_limit INT DEFAULT 30,
  p_status TEXT DEFAULT NULL,
  p_visibility TEXT DEFAULT NULL,
  p_stance TEXT DEFAULT NULL,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (session_id UUID) AS $$
BEGIN
  RETURN QUERY
  SELECT s.id AS session_id
  FROM interview_sessions s
  LEFT JOIN interview_report r
    ON r.interview_session_id = s.id
  WHERE s.interview_config_id = p_config_id
    AND (p_status IS NULL OR
         (p_status = 'completed' AND s.completed_at IS NOT NULL) OR
         (p_status = 'in_progress' AND s.completed_at IS NULL AND s.archived_at IS NULL) OR
         (p_status = 'archived' AND s.completed_at IS NULL AND s.archived_at IS NOT NULL))
    AND (p_visibility IS NULL OR
         (p_visibility = 'public' AND r.is_public_by_admin = TRUE) OR
         (p_visibility = 'private' AND r.is_public_by_admin = FALSE))
    AND (p_stance IS NULL OR r.stance = p_stance::stance_type_enum)
    AND (p_role IS NULL OR r.role = p_role::interview_report_role_enum)
  ORDER BY
    CASE WHEN p_ascending THEN r.moderation_score END ASC NULLS LAST,
    CASE WHEN NOT p_ascending THEN r.moderation_score END DESC NULLS LAST,
    s.started_at DESC,
    s.id DESC
  OFFSET p_offset
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;
-- レポート一括公開: 対象件数カウントと一括更新のDB関数

-- 対象件数カウント
create function count_bulk_publish_targets(
  p_config_id uuid,
  p_max_moderation_score integer,
  p_min_content_richness integer
) returns bigint as $$
  select count(*)
  from interview_report r
  join interview_sessions s on s.id = r.interview_session_id
  where s.interview_config_id = p_config_id
    and r.is_public_by_user = true
    and r.is_public_by_admin = false
    and r.moderation_score is not null
    and r.moderation_score <= p_max_moderation_score
    and r.total_content_richness is not null
    and r.total_content_richness >= p_min_content_richness;
$$ language sql stable;

-- 一括公開実行（更新件数を返す）
create function bulk_publish_reports(
  p_config_id uuid,
  p_max_moderation_score integer,
  p_min_content_richness integer
) returns bigint as $$
  with updated as (
    update interview_report r
    set is_public_by_admin = true
    from interview_sessions s
    where s.id = r.interview_session_id
      and s.interview_config_id = p_config_id
      and r.is_public_by_user = true
      and r.is_public_by_admin = false
      and r.moderation_score is not null
      and r.moderation_score <= p_max_moderation_score
      and r.total_content_richness is not null
      and r.total_content_richness >= p_min_content_richness
    returning r.id
  )
  select count(*) from updated;
$$ language sql volatile;
-- get_interview_statistics にコスト集計（トータルコスト・平均コスト）を追加
drop function if exists get_interview_statistics(uuid);

create function get_interview_statistics(p_config_id uuid)
returns table (
  total_sessions bigint,
  completed_sessions bigint,
  avg_rating numeric,
  stance_for_count bigint,
  stance_against_count bigint,
  stance_neutral_count bigint,
  avg_total_content_richness numeric,
  role_subject_expert_count bigint,
  role_work_related_count bigint,
  role_daily_life_affected_count bigint,
  role_general_citizen_count bigint,
  avg_message_count numeric,
  median_duration_seconds numeric,
  public_by_user_count bigint,
  feedback_irrelevant_questions bigint,
  feedback_not_aligned bigint,
  feedback_misunderstood bigint,
  feedback_too_many_questions bigint,
  feedback_other bigint,
  total_cost_usd numeric,
  avg_cost_usd numeric
) as $$
begin
  return query
  select
    count(s.id) as total_sessions,
    count(s.completed_at) as completed_sessions,
    round(avg(s.rating)::numeric, 2) as avg_rating,
    count(case when r.stance = 'for' then 1 end) as stance_for_count,
    count(case when r.stance = 'against' then 1 end) as stance_against_count,
    count(case when r.stance = 'neutral' then 1 end) as stance_neutral_count,
    round(avg(r.total_content_richness)::numeric, 1) as avg_total_content_richness,
    count(case when r.role = 'subject_expert' then 1 end) as role_subject_expert_count,
    count(case when r.role = 'work_related' then 1 end) as role_work_related_count,
    count(case when r.role = 'daily_life_affected' then 1 end) as role_daily_life_affected_count,
    count(case when r.role = 'general_citizen' then 1 end) as role_general_citizen_count,
    round(avg(coalesce(mc.message_count, 0))::numeric, 1) as avg_message_count,
    round(
      (select percentile_cont(0.5) within group (
        order by extract(epoch from (sub.completed_at - sub.started_at))
      )
      from interview_sessions sub
      where sub.interview_config_id = p_config_id
        and sub.completed_at is not null
      )::numeric, 0
    ) as median_duration_seconds,
    count(case when r.is_public_by_user = true then 1 end) as public_by_user_count,
    -- フィードバックタグ集計
    coalesce(max(fc.feedback_irrelevant_questions), 0) as feedback_irrelevant_questions,
    coalesce(max(fc.feedback_not_aligned), 0) as feedback_not_aligned,
    coalesce(max(fc.feedback_misunderstood), 0) as feedback_misunderstood,
    coalesce(max(fc.feedback_too_many_questions), 0) as feedback_too_many_questions,
    coalesce(max(fc.feedback_other), 0) as feedback_other,
    -- コスト集計
    coalesce(max(cc.total_cost), 0)::numeric as total_cost_usd,
    case
      when count(s.id) > 0 then round(coalesce(max(cc.total_cost), 0)::numeric / count(s.id), 6)
      else 0::numeric
    end as avg_cost_usd
  from interview_sessions s
  left join interview_report r on r.interview_session_id = s.id
  left join (
    select im.interview_session_id, count(*) as message_count
    from interview_messages im
    group by im.interview_session_id
  ) mc on mc.interview_session_id = s.id
  left join (
    select
      count(*) filter (where f.tag = 'irrelevant_questions') as feedback_irrelevant_questions,
      count(*) filter (where f.tag = 'not_aligned') as feedback_not_aligned,
      count(*) filter (where f.tag = 'misunderstood') as feedback_misunderstood,
      count(*) filter (where f.tag = 'too_many_questions') as feedback_too_many_questions,
      count(*) filter (where f.tag = 'other') as feedback_other
    from interview_rating_feedbacks f
    join interview_sessions fs on fs.id = f.interview_session_id
    where fs.interview_config_id = p_config_id
  ) fc on true
  left join (
    select sum(c.cost_usd) as total_cost
    from chat_usage_events c
    join interview_sessions cs on cs.id::text = c.session_id
    where cs.interview_config_id = p_config_id
  ) cc on true
  where s.interview_config_id = p_config_id;
end;
$$ language plpgsql stable;

-- session_id での結合を高速化するインデックス
create index if not exists chat_usage_events_session_id_idx
  on public.chat_usage_events (session_id);
-- 複数のinterview_config_idに対するセッション数を一括取得するRPC関数
create or replace function count_sessions_by_config_ids(p_config_ids uuid[])
returns table (
  interview_config_id uuid,
  session_count bigint
)
language sql
stable
as $$
  select
    s.interview_config_id,
    count(s.id) as session_count
  from interview_sessions s
  where s.interview_config_id = any(p_config_ids)
  group by s.interview_config_id;
$$;
-- bills テーブルに記事レビュー完了フラグを追加
ALTER TABLE bills ADD COLUMN is_review_completed BOOLEAN NOT NULL DEFAULT false;

-- 既に公開済みの議案はレビュー完了済みとする
UPDATE bills SET is_review_completed = true WHERE publish_status = 'published';

COMMENT ON COLUMN bills.is_review_completed IS '記事のレビューが完了しているかどうか（falseの場合、記事にレビュー中バナーが表示される）';
-- Zero-downtime rename: published_at → submitted_date
-- Phase 1: Add submitted_date column with sync trigger (this migration)
-- Phase 2: Drop published_at column and trigger (future migration)

-- 1. Add new column
ALTER TABLE bills ADD COLUMN submitted_date TIMESTAMP WITH TIME ZONE;

-- 2. Copy existing data
UPDATE bills SET submitted_date = published_at;

-- 3. Create bidirectional sync trigger for transition period
CREATE OR REPLACE FUNCTION sync_bills_published_submitted() RETURNS trigger AS $$
BEGIN
  -- When old code writes published_at, sync to submitted_date
  IF (TG_OP = 'UPDATE' AND NEW.published_at IS DISTINCT FROM OLD.published_at AND NEW.submitted_date IS NOT DISTINCT FROM OLD.submitted_date) THEN
    NEW.submitted_date := NEW.published_at;
  -- When new code writes submitted_date, sync to published_at
  ELSIF (TG_OP = 'UPDATE' AND NEW.submitted_date IS DISTINCT FROM OLD.submitted_date AND NEW.published_at IS NOT DISTINCT FROM OLD.published_at) THEN
    NEW.published_at := NEW.submitted_date;
  -- When both change simultaneously, submitted_date wins (new code is authoritative)
  ELSIF (TG_OP = 'UPDATE' AND NEW.published_at IS DISTINCT FROM OLD.published_at AND NEW.submitted_date IS DISTINCT FROM OLD.submitted_date) THEN
    NEW.published_at := NEW.submitted_date;
  -- On INSERT, sync whichever is provided
  ELSIF (TG_OP = 'INSERT') THEN
    IF NEW.submitted_date IS NOT NULL AND NEW.published_at IS NOT NULL AND NEW.published_at IS DISTINCT FROM NEW.submitted_date THEN
      -- Both provided but inconsistent: new column wins during transition
      NEW.published_at := NEW.submitted_date;
    ELSIF NEW.submitted_date IS NULL AND NEW.published_at IS NOT NULL THEN
      NEW.submitted_date := NEW.published_at;
    ELSIF NEW.published_at IS NULL AND NEW.submitted_date IS NOT NULL THEN
      NEW.published_at := NEW.submitted_date;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_sync_bills_published_submitted
  BEFORE INSERT OR UPDATE ON bills
  FOR EACH ROW EXECUTE FUNCTION sync_bills_published_submitted();

-- 4. Add index on new column
CREATE INDEX idx_bills_submitted_date ON bills(submitted_date DESC);

-- 5. Add comment
COMMENT ON COLUMN bills.submitted_date IS '法案提出日';
alter table bills add column slug text;

create unique index idx_bills_slug on bills (slug);
-- team-mir.ai ドメインの Google ログインユーザーに admin ロールを付与する関数
-- トリガーから呼ばれるが、テスト用に直接呼び出しも可能
CREATE OR REPLACE FUNCTION public.apply_admin_role_if_eligible(target_user_id uuid)
RETURNS boolean AS $$
DECLARE
  user_email text;
  user_provider text;
  current_roles jsonb;
BEGIN
  SELECT email, raw_app_meta_data->>'provider', raw_app_meta_data->'roles'
  INTO user_email, user_provider, current_roles
  FROM auth.users WHERE id = target_user_id;

  IF user_email ILIKE '%@team-mir.ai'
    AND user_provider = 'google'
    AND (current_roles IS NULL OR NOT current_roles @> '["admin"]')
  THEN
    UPDATE auth.users
    SET raw_app_meta_data = jsonb_set(
      COALESCE(raw_app_meta_data, '{}'::jsonb),
      '{roles}',
      COALESCE(raw_app_meta_data->'roles', '[]'::jsonb) || '["admin"]'::jsonb
    )
    WHERE id = target_user_id;
    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガー関数: AFTER INSERT で上記関数を呼び出す
CREATE OR REPLACE FUNCTION public.handle_google_workspace_admin_role()
RETURNS trigger AS $$
BEGIN
  PERFORM public.apply_admin_role_if_eligible(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created_set_admin_role
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_google_workspace_admin_role();

-- 既存の team-mir.ai Google ログインユーザーにも admin ロールを付与
UPDATE auth.users
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{roles}',
  COALESCE(raw_app_meta_data->'roles', '[]'::jsonb) || '["admin"]'::jsonb
)
WHERE email ILIKE '%@team-mir.ai'
  AND raw_app_meta_data->>'provider' = 'google'
  AND (
    raw_app_meta_data->'roles' IS NULL
    OR NOT raw_app_meta_data->'roles' @> '["admin"]'
  );
-- bills テーブルに knowledge_source と use_knowledge_source_in_chat を追加し、
-- 既存の interview_configs.knowledge_source を bills 側に移設する。
--
-- 背景: AIチャットでもナレッジソースを参照できるようにしたいが、
-- ナレッジは「議案に紐づく事実情報」なので bills に持たせるのが自然。
-- インタビュー設定の作成を前提にせずチャットでも使えるようにする。

ALTER TABLE bills
  ADD COLUMN knowledge_source TEXT,
  ADD COLUMN use_knowledge_source_in_chat BOOLEAN NOT NULL DEFAULT false;

-- 既存の interview_configs.knowledge_source を bills 側へコピーする。
-- 同一 bill に複数 config がある場合は、公開中 (status='public') を最優先し、
-- 同条件内では updated_at が最新のものを採用する。
UPDATE bills b
SET knowledge_source = sub.knowledge_source
FROM (
  SELECT DISTINCT ON (bill_id)
    bill_id,
    knowledge_source
  FROM interview_configs
  WHERE knowledge_source IS NOT NULL
    AND btrim(knowledge_source) <> ''
  ORDER BY bill_id, (status = 'public') DESC, updated_at DESC, id DESC
) sub
WHERE b.id = sub.bill_id;

ALTER TABLE interview_configs DROP COLUMN knowledge_source;
-- Add 'targeted' value to interview_mode_enum and target_audience column to interview_questions.
--
-- targeted モード: loop モードと同様の都度深掘りに加え、各質問に「対象者条件」を任意で付与できる。
-- 対象者条件にマッチしないインタビュイーには当該質問をスキップする。

ALTER TYPE interview_mode_enum ADD VALUE IF NOT EXISTS 'targeted';

ALTER TABLE interview_questions
ADD COLUMN target_audience TEXT;

COMMENT ON COLUMN interview_questions.target_audience IS
  '対象者条件（任意）。指定された場合、LLMが会話文脈からインタビュイーの該当性を判定し、非該当なら質問をスキップする。targetedモードでのみ利用される。';
-- get_interview_statistics に総所要時間（途中離脱含む）を追加
-- 完了セッション: completed_at - started_at
-- 途中離脱セッション: 最後のメッセージ created_at - started_at（メッセージが無いセッションは集計から除外）
drop function if exists get_interview_statistics(uuid);

create function get_interview_statistics(p_config_id uuid)
returns table (
  total_sessions bigint,
  completed_sessions bigint,
  avg_rating numeric,
  stance_for_count bigint,
  stance_against_count bigint,
  stance_neutral_count bigint,
  avg_total_content_richness numeric,
  role_subject_expert_count bigint,
  role_work_related_count bigint,
  role_daily_life_affected_count bigint,
  role_general_citizen_count bigint,
  avg_message_count numeric,
  median_duration_seconds numeric,
  total_duration_seconds numeric,
  public_by_user_count bigint,
  feedback_irrelevant_questions bigint,
  feedback_not_aligned bigint,
  feedback_misunderstood bigint,
  feedback_too_many_questions bigint,
  feedback_other bigint,
  total_cost_usd numeric,
  avg_cost_usd numeric
) as $$
begin
  return query
  select
    count(s.id) as total_sessions,
    count(s.completed_at) as completed_sessions,
    round(avg(s.rating)::numeric, 2) as avg_rating,
    count(case when r.stance = 'for' then 1 end) as stance_for_count,
    count(case when r.stance = 'against' then 1 end) as stance_against_count,
    count(case when r.stance = 'neutral' then 1 end) as stance_neutral_count,
    round(avg(r.total_content_richness)::numeric, 1) as avg_total_content_richness,
    count(case when r.role = 'subject_expert' then 1 end) as role_subject_expert_count,
    count(case when r.role = 'work_related' then 1 end) as role_work_related_count,
    count(case when r.role = 'daily_life_affected' then 1 end) as role_daily_life_affected_count,
    count(case when r.role = 'general_citizen' then 1 end) as role_general_citizen_count,
    round(avg(coalesce(mc.message_count, 0))::numeric, 1) as avg_message_count,
    round(
      (select percentile_cont(0.5) within group (
        order by extract(epoch from (sub.completed_at - sub.started_at))
      )
      from interview_sessions sub
      where sub.interview_config_id = p_config_id
        and sub.completed_at is not null
      )::numeric, 0
    ) as median_duration_seconds,
    -- 総所要時間: 完了セッションは completed_at、途中離脱は最終メッセージ時刻を終了時刻として集計
    -- メッセージが無い未完了セッションは duration を算出できないため除外
    coalesce(
      (select sum(extract(epoch from (
        coalesce(sub.completed_at, lm.last_message_at) - sub.started_at
      )))
      from interview_sessions sub
      left join (
        select im.interview_session_id, max(im.created_at) as last_message_at
        from interview_messages im
        group by im.interview_session_id
      ) lm on lm.interview_session_id = sub.id
      where sub.interview_config_id = p_config_id
        and coalesce(sub.completed_at, lm.last_message_at) is not null
      ),
      0
    )::numeric as total_duration_seconds,
    count(case when r.is_public_by_user = true then 1 end) as public_by_user_count,
    -- フィードバックタグ集計
    coalesce(max(fc.feedback_irrelevant_questions), 0) as feedback_irrelevant_questions,
    coalesce(max(fc.feedback_not_aligned), 0) as feedback_not_aligned,
    coalesce(max(fc.feedback_misunderstood), 0) as feedback_misunderstood,
    coalesce(max(fc.feedback_too_many_questions), 0) as feedback_too_many_questions,
    coalesce(max(fc.feedback_other), 0) as feedback_other,
    -- コスト集計
    coalesce(max(cc.total_cost), 0)::numeric as total_cost_usd,
    case
      when count(s.id) > 0 then round(coalesce(max(cc.total_cost), 0)::numeric / count(s.id), 6)
      else 0::numeric
    end as avg_cost_usd
  from interview_sessions s
  left join interview_report r on r.interview_session_id = s.id
  left join (
    select im.interview_session_id, count(*) as message_count
    from interview_messages im
    group by im.interview_session_id
  ) mc on mc.interview_session_id = s.id
  left join (
    select
      count(*) filter (where f.tag = 'irrelevant_questions') as feedback_irrelevant_questions,
      count(*) filter (where f.tag = 'not_aligned') as feedback_not_aligned,
      count(*) filter (where f.tag = 'misunderstood') as feedback_misunderstood,
      count(*) filter (where f.tag = 'too_many_questions') as feedback_too_many_questions,
      count(*) filter (where f.tag = 'other') as feedback_other
    from interview_rating_feedbacks f
    join interview_sessions fs on fs.id = f.interview_session_id
    where fs.interview_config_id = p_config_id
  ) fc on true
  left join (
    select sum(c.cost_usd) as total_cost
    from chat_usage_events c
    join interview_sessions cs on cs.id::text = c.session_id
    where cs.interview_config_id = p_config_id
  ) cc on true
  where s.interview_config_id = p_config_id;
end;
$$ language plpgsql stable;

-- function を drop すると権限もリセットされるため、admin-only 権限を再付与
revoke execute on function public.get_interview_statistics(uuid) from public;
revoke execute on function public.get_interview_statistics(uuid) from anon;
revoke execute on function public.get_interview_statistics(uuid) from authenticated;
grant execute on function public.get_interview_statistics(uuid) to service_role;
-- ユーザー向けトピック分析機能の土台となる interview_opinion テーブルを作成
-- interview_report.opinions(JSONB) を正本とし、本テーブルはそこから導出する
-- 正規化プロジェクション（読み取りモデル）。dual-write で同期する（§3.1）。
-- opinion_id(UUID) を安定させるため、同期は delete+insert ではなく
-- ON CONFLICT (interview_report_id, opinion_index) DO UPDATE で行う。

CREATE TABLE interview_opinion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_report_id UUID NOT NULL REFERENCES interview_report(id) ON DELETE CASCADE,
  opinion_index SMALLINT NOT NULL,              -- レポート内の順序（0..2）
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  source_message_id UUID,                        -- 元発言の引用が紐づくメッセージ
  contextual_quote TEXT,                         -- 文脈込み引用（自己完結。§4.0）
  bill_sentiment TEXT,                           -- '期待' | '懸念' | NULL
  richness INTEGER,                              -- 任意（無ければ report 側の total_content_richness を使う）
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE (interview_report_id, opinion_index)
);

-- レポート単位の同期・分析対象抽出のためのインデックス
CREATE INDEX idx_interview_opinion_report_id ON interview_opinion(interview_report_id);

-- Enable Row Level Security
ALTER TABLE interview_opinion ENABLE ROW LEVEL SECURITY;

-- No policies are created, so all access is denied by default
-- Access will only be possible using Supabase Service Role Key from server-side

-- Add comments for documentation
COMMENT ON TABLE interview_opinion IS 'interview_report.opinions(JSONB)から導出する意見の正規化プロジェクション（トピック分析用の読み取りモデル）';
COMMENT ON COLUMN interview_opinion.interview_report_id IS '元レポートID';
COMMENT ON COLUMN interview_opinion.opinion_index IS 'レポート内の意見の順序（0始まり）';
COMMENT ON COLUMN interview_opinion.title IS '意見のタイトル';
COMMENT ON COLUMN interview_opinion.content IS '意見の説明';
COMMENT ON COLUMN interview_opinion.source_message_id IS '根拠となるユーザー発言のメッセージID';
COMMENT ON COLUMN interview_opinion.contextual_quote IS '文脈込みの自己完結した引用（個人名等の固有名詞は含めない）';
COMMENT ON COLUMN interview_opinion.bill_sentiment IS '法案に対する期待/懸念（期待|懸念|NULL）';
COMMENT ON COLUMN interview_opinion.richness IS '意見単位の情報充実度（任意）';
-- 意見再抽出バックフィル（Step 2）の進捗追跡用カラム。
-- NULL = 未再抽出。チャンク処理が完了するごとに now() を記録し、
-- 再開可能・冪等（NULL に戻せば再処理対象に戻る）にする。
ALTER TABLE interview_report
  ADD COLUMN opinions_reextracted_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN interview_report.opinions_reextracted_at IS '意見再抽出バックフィルの完了時刻（NULL=未処理）';
-- ユーザー向けトピック分析（Step 3）の分析結果テーブル。
-- 既存の admin 用 topic_analysis_versions/_topics/_classifications とは完全に独立（設計§10）。
-- 意見は interview_opinion（正規化プロジェクション）を参照する。

CREATE TYPE topic_analysis_status AS ENUM (
  'pending',
  'running',
  'completed',
  'failed'
);

-- 分析バージョン（bill 内連番。バージョニングと公開管理の中心。§3.2）
CREATE TABLE topic_analysis_version (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,                       -- bill 内の連番
  status topic_analysis_status NOT NULL DEFAULT 'pending',
  is_published BOOLEAN NOT NULL DEFAULT false,    -- 公開フラグ（§7。Step4aで制御）

  -- 実行制御（§5 の状態機械）
  current_step TEXT,                              -- 'extract' | 'merge' | 'assign' | 'done'
  progress JSONB,                                 -- フェーズ間の中間結果・進捗

  -- 監査・再現
  trigger TEXT NOT NULL,                          -- 'cron' | 'manual'
  model TEXT,                                     -- 使用モデル
  prompt_version TEXT,                            -- プロンプト版
  source_opinion_count INTEGER,                   -- 分析時点の対象意見数（watermark, §6）

  error_message TEXT,
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE (bill_id, version)
);

-- 公開は bill ごとに最大1版（部分ユニークインデックス。§3.2）
CREATE UNIQUE INDEX one_published_per_bill
  ON topic_analysis_version (bill_id) WHERE is_published;

-- 実行中（pending/running）は bill ごとに最大1版（二重起動の原子的ガード・§5.3）。
-- アプリ層の事前チェックは TOCTOU で破れるため、DB 側でも一意制約を持たせる。
CREATE UNIQUE INDEX one_active_version_per_bill
  ON topic_analysis_version (bill_id) WHERE status IN ('pending', 'running');

CREATE INDEX idx_topic_analysis_version_bill ON topic_analysis_version(bill_id);

-- トピック（§3.3）
CREATE TABLE topic (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id UUID NOT NULL REFERENCES topic_analysis_version(id) ON DELETE CASCADE,
  title TEXT NOT NULL,                            -- 主張文体・20字程度
  description TEXT NOT NULL,                      -- 論点の説明 60〜80字
  sort_order INTEGER NOT NULL DEFAULT 0,          -- opinion件数降順などの表示順
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_topic_version ON topic(version_id);

-- 意見へのトピック割当（§3.4）。1意見は最大1トピック（0 or 1）。未分類は行なし。
CREATE TABLE topic_opinion (
  topic_id UUID NOT NULL REFERENCES topic(id) ON DELETE CASCADE,
  opinion_id UUID NOT NULL REFERENCES interview_opinion(id) ON DELETE CASCADE,
  version_id UUID NOT NULL REFERENCES topic_analysis_version(id) ON DELETE CASCADE,
  PRIMARY KEY (version_id, opinion_id)            -- 1意見最大1トピックを強制
);

CREATE INDEX idx_topic_opinion_topic ON topic_opinion(topic_id);

-- Enable Row Level Security（ポリシーは定義しない＝デフォルト全拒否）
ALTER TABLE topic_analysis_version ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_opinion ENABLE ROW LEVEL SECURITY;

-- No policies are created, so all access is denied by default.
-- Access is via Supabase Secret Key from server-side only.

COMMENT ON TABLE topic_analysis_version IS 'ユーザー向けトピック分析のバージョン（bill内連番・公開管理の中心）';
COMMENT ON COLUMN topic_analysis_version.is_published IS '公開フラグ。bill毎に最大1版（部分unique）。Step4aで制御';
COMMENT ON COLUMN topic_analysis_version.current_step IS 'extract | merge | assign | done';
COMMENT ON COLUMN topic_analysis_version.progress IS 'フェーズ間の中間結果（抽出候補・最終トピック・割当）';
COMMENT ON COLUMN topic_analysis_version.source_opinion_count IS '分析時点の対象意見数（§8フィルタ後）';
COMMENT ON TABLE topic IS 'トピック（主張文体タイトル＋論点説明）';
COMMENT ON TABLE topic_opinion IS '意見→トピックの割当（version スコープ・1意見最大1トピック）';
-- topic_opinion.topic_id と version_id が独立した外部キーのままだと、
-- 別バージョンの topic を参照する行を作れてしまう（CodeRabbit #828 指摘）。
-- topic(version_id, id) への複合外部キーに置き換え、同一バージョン内の topic しか
-- 参照できないように強制する。topic_opinion は本番未使用のため既存データ移行は不要。

-- 複合FKの参照先となる一意制約（id は PK だが複合参照には明示的な UNIQUE が必要）
ALTER TABLE topic
  ADD CONSTRAINT topic_version_id_id_key UNIQUE (version_id, id);

-- 独立していた topic_id 単独FKを外し、(version_id, topic_id) の複合FKに置き換える
ALTER TABLE topic_opinion
  DROP CONSTRAINT topic_opinion_topic_id_fkey;

ALTER TABLE topic_opinion
  ADD CONSTRAINT topic_opinion_topic_fk
  FOREIGN KEY (version_id, topic_id)
  REFERENCES topic (version_id, id)
  ON DELETE CASCADE;
-- version の公開切替を「旧公開版を降ろす → 対象を公開」を1トランザクションで行う関数。
-- アプリ層で2回 update（各 auto-commit）すると、その間に公開版が0件の瞬間が
-- 外部トランザクションから見えてしまい、公開読み取りが一時的に404（準備中）になる。
-- 関数内（単一トランザクション）で実行することで、外部からは旧公開→新公開へ
-- アトミックに切り替わって見える（中間状態は不可視）。one_published_per_bill も満たす。
CREATE OR REPLACE FUNCTION publish_topic_analysis_version(p_version_id UUID)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_bill_id UUID;
BEGIN
  SELECT bill_id INTO v_bill_id
  FROM topic_analysis_version
  WHERE id = p_version_id;

  IF v_bill_id IS NULL THEN
    RAISE EXCEPTION 'topic_analysis_version % not found', p_version_id;
  END IF;

  -- 先に同 bill の現公開版を降ろす（同一トランザクション内なので部分ユニーク制約に衝突しない）
  UPDATE topic_analysis_version
  SET is_published = false
  WHERE bill_id = v_bill_id
    AND is_published = true
    AND id <> p_version_id;

  -- 対象を公開
  UPDATE topic_analysis_version
  SET is_published = true
  WHERE id = p_version_id;
END;
$$;
-- interview_opinion は当初 interview_report.opinions(JSONB) から導出する
-- 「正規化プロジェクション」として作られたが、意見再抽出は JSONB を書き換えず
-- interview_opinion テーブルのみ更新する方針に変更した。
-- そのため本テーブルは JSONB の派生ではなく、トピック分析用の意見ストアとして独立する。
-- （新規インタビュー完了時のみ JSONB と本テーブルの両方へ互換目的で書き込む。）
COMMENT ON TABLE interview_opinion IS 'トピック分析用の意見ストア。新規インタビュー完了時は interview_report.opinions(JSONB) と本テーブルの両方へ書き込み、意見再抽出は本テーブルのみ更新する（JSONB は原本として保持）';
-- 増分トピック分析用の抽出ウォーターマーク。
-- トピック抽出(Phase1)の対象に含めた意見に時刻を記録する。
-- NULL = まだ一度もトピック抽出にかけられていない「新規意見」（増分抽出の対象）。
ALTER TABLE interview_opinion
  ADD COLUMN topic_extracted_at TIMESTAMPTZ;

COMMENT ON COLUMN interview_opinion.topic_extracted_at IS
  'トピック抽出(Phase1)の対象に含めた時刻。NULL=未抽出(増分トピック分析の新規対象)';
-- 増分トピック分析: 指定意見群のトピック抽出済みウォーターマークを
-- 単一 UPDATE で原子的に記録する。アプリ層で id をチャンク分割して複数回更新すると、
-- 途中失敗時に一部だけ topic_extracted_at が進んだ半端な状態が残るため、
-- 配列引数を受ける関数に寄せて all-or-nothing にする（PostgREST の URL 長制限も回避）。
CREATE OR REPLACE FUNCTION mark_opinions_extracted(
  p_ids UUID[],
  p_extracted_at TIMESTAMPTZ
) RETURNS VOID
LANGUAGE sql
AS $$
  UPDATE interview_opinion
  SET topic_extracted_at = p_extracted_at
  WHERE id = ANY(p_ids);
$$;

COMMENT ON FUNCTION mark_opinions_extracted(UUID[], TIMESTAMPTZ) IS
  '指定意見群の topic_extracted_at を単一トランザクションで一括更新する（増分トピック分析の抽出済み記録）';
-- interview_configsテーブルにdeleted_atカラムを追加
-- 管理画面からインタビュー設定を削除した場合に設定される（論理削除）
-- 物理削除（CASCADE）の代わりに、deleted_atを設定して一覧・公開取得から除外する
ALTER TABLE interview_configs ADD COLUMN deleted_at TIMESTAMPTZ;
-- インタビュー設定の論理削除に伴い、配下レポートを一括で公開停止するRPC関数
-- 設定削除時に呼び出し、対象configのセッションに紐づく公開レポートの
-- is_public_by_admin を false にする。
-- アプリ層でセッションIDを取得して .in() で更新する方式は PostgREST の
-- 行数上限（既定1000件）に引っかかるため、DB側の UPDATE ... FROM で一括更新する。
create or replace function unpublish_reports_by_config_id(p_config_id uuid)
returns void
language sql
as $$
  update interview_report r
  set is_public_by_admin = false
  from interview_sessions s
  where r.interview_session_id = s.id
    and s.interview_config_id = p_config_id
    and r.is_public_by_admin = true;
$$;
ALTER TYPE stance_type_enum ADD VALUE 'free_vote';
-- 議案ごとのAIインタビュー実施状況（実施数・完了数・完了率）を集計するRPC関数。
-- admin MCP tool (get_interview_metrics_by_bill) から利用する。
--
-- 定義:
--   実施数 (conducted_count): interview_sessions の総数（開始されたセッション。archived含む）
--   完了数 (completed_count): completed_at が設定されたセッション数
--   完了率 (completion_rate): completed_count / conducted_count（0〜1、小数第3位で丸め。実施0件は0）
--
-- 論理削除済みの設定（interview_configs.deleted_at IS NOT NULL）は除外する。
-- 1議案に複数の設定がある場合は設定を跨いで合算する。
-- p_bill_id を指定するとその議案のみ、NULL（未指定）なら設定を持つ全議案を返す。
create or replace function get_interview_metrics_by_bill(p_bill_id uuid default null)
returns table (
  bill_id uuid,
  bill_name text,
  conducted_count bigint,
  completed_count bigint,
  completion_rate numeric
)
language sql
stable
as $$
  select
    b.id as bill_id,
    b.name as bill_name,
    count(s.id) as conducted_count,
    count(s.completed_at) as completed_count,
    case
      when count(s.id) = 0 then 0
      else round(count(s.completed_at)::numeric / count(s.id)::numeric, 3)
    end as completion_rate
  from bills b
  join interview_configs c
    on c.bill_id = b.id
   and c.deleted_at is null
  left join interview_sessions s
    on s.interview_config_id = c.id
  where p_bill_id is null or b.id = p_bill_id
  group by b.id, b.name
  order by count(s.id) desc, b.name;
$$;

comment on function get_interview_metrics_by_bill(uuid) is
  '議案ごとのAIインタビュー実施数・完了数・完了率を集計する。論理削除済み設定は除外。p_bill_idで単一議案に絞り込める。';
-- Add is_data_reuse_consented column to interview_report table
-- インタビューデータの二次利用（オープンデータとしての第三者提供）に対する
-- ユーザーの利用許諾を記録する。
-- 新しい利用規約（データの第三者提供を含む）を確認した上で同意した場合のみ true。
-- 過去のレポートおよび新規約の確認前に提出されたレポートは false のまま。

ALTER TABLE interview_report
ADD COLUMN is_data_reuse_consented BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN interview_report.is_data_reuse_consented IS 'ユーザーがデータの二次利用（オープンデータとしての第三者提供）に同意したか（新利用規約を確認した上での同意のみ true）';
-- get_interview_metrics_by_bill に総回答時間（total_duration_seconds）を追加する。
-- 既存の実施数・完了数・完了率に加え、議案ごとに回答へ費やされた総時間（秒）を返す。
--
-- 総回答時間の定義（get_interview_statistics の total_duration_seconds と揃える）:
--   完了セッション: completed_at - started_at
--   途中離脱セッション: 最後のメッセージ created_at - started_at
--   メッセージが無い未完了セッションは終了時刻を確定できないため集計から除外する
-- 秒単位・小数第0位で丸め、集計対象が無い議案は0とする。
--
-- RETURNS TABLE に列を追加するため、CREATE OR REPLACE ではなく DROP してから作り直す。
drop function if exists get_interview_metrics_by_bill(uuid);

create function get_interview_metrics_by_bill(p_bill_id uuid default null)
returns table (
  bill_id uuid,
  bill_name text,
  conducted_count bigint,
  completed_count bigint,
  completion_rate numeric,
  total_duration_seconds numeric
)
language sql
stable
as $$
  select
    b.id as bill_id,
    b.name as bill_name,
    count(s.id) as conducted_count,
    count(s.completed_at) as completed_count,
    case
      when count(s.id) = 0 then 0
      else round(count(s.completed_at)::numeric / count(s.id)::numeric, 3)
    end as completion_rate,
    round(
      coalesce(
        sum(
          extract(
            epoch from (coalesce(s.completed_at, lm.last_message_at) - s.started_at)
          )
        ),
        0
      )::numeric,
      0
    ) as total_duration_seconds
  from bills b
  join interview_configs c
    on c.bill_id = b.id
   and c.deleted_at is null
  left join interview_sessions s
    on s.interview_config_id = c.id
  left join (
    select im.interview_session_id, max(im.created_at) as last_message_at
    from interview_messages im
    group by im.interview_session_id
  ) lm
    on lm.interview_session_id = s.id
  where p_bill_id is null or b.id = p_bill_id
  group by b.id, b.name
  order by count(s.id) desc, b.name;
$$;

comment on function get_interview_metrics_by_bill(uuid) is
  '議案ごとのAIインタビュー実施数・完了数・完了率・総回答時間（秒）を集計する。論理削除済み設定は除外。p_bill_idで単一議案に絞り込める。';
-- Compute per-question respondent counts for a given interview config
-- Used for admin interview report list page statistics display

-- Extract the interview_questions.id an assistant message asked.
-- An assistant message's content is a JSON string carrying the asked
-- question id as "question_id" (legacy: "questionId"). Returns NULL for
-- legacy plain-text messages, non-object JSON, or non-UUID ids.
-- Keep in sync with the TypeScript parser:
-- web/src/features/interview-session/shared/message-utils.ts (parseMessageContent)
-- Requires PostgreSQL 16+ (pg_input_is_valid). This project runs PG 17
-- (see supabase/config.toml major_version).
CREATE OR REPLACE FUNCTION extract_assistant_question_id(content TEXT)
RETURNS UUID AS $$
DECLARE
  parsed JSONB;
  question_id_text TEXT;
BEGIN
  IF content IS NULL OR NOT pg_input_is_valid(content, 'jsonb') THEN
    RETURN NULL;
  END IF;

  parsed := content::jsonb;
  IF jsonb_typeof(parsed) <> 'object' THEN
    RETURN NULL;
  END IF;

  question_id_text := COALESCE(
    parsed ->> 'question_id',
    parsed ->> 'questionId'
  );
  IF question_id_text IS NULL
    OR NOT pg_input_is_valid(question_id_text, 'uuid') THEN
    RETURN NULL;
  END IF;

  RETURN question_id_text::uuid;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- A question counts as "asked" in a session when an assistant message
-- referencing it exists, and as "answered" when a user message exists
-- after that assistant message.
CREATE OR REPLACE FUNCTION get_question_answer_counts(p_config_id UUID)
RETURNS TABLE (
  question_id UUID,
  question TEXT,
  question_order INTEGER,
  asked_session_count BIGINT,
  answered_session_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH asked AS (
    SELECT t.session_id, t.created_at, t.qid
    FROM (
      SELECT
        m.interview_session_id AS session_id,
        m.created_at,
        extract_assistant_question_id(m.content) AS qid
      FROM interview_messages m
      JOIN interview_sessions s ON s.id = m.interview_session_id
      WHERE s.interview_config_id = p_config_id
        AND m.role = 'assistant'
    ) t
    WHERE t.qid IS NOT NULL
  ),
  last_user_message AS (
    SELECT
      m.interview_session_id AS session_id,
      MAX(m.created_at) AS last_user_at
    FROM interview_messages m
    JOIN interview_sessions s ON s.id = m.interview_session_id
    WHERE s.interview_config_id = p_config_id
      AND m.role = 'user'
    GROUP BY m.interview_session_id
  )
  SELECT
    q.id AS question_id,
    q.question,
    q.question_order,
    COUNT(DISTINCT a.session_id) AS asked_session_count,
    COUNT(DISTINCT a.session_id) FILTER (WHERE lu.last_user_at > a.created_at)
      AS answered_session_count
  FROM interview_questions q
  LEFT JOIN asked a ON a.qid = q.id
  LEFT JOIN last_user_message lu ON lu.session_id = a.session_id
  WHERE q.interview_config_id = p_config_id
  GROUP BY q.id, q.question, q.question_order
  ORDER BY q.question_order;
END;
$$ LANGUAGE plpgsql STABLE;
-- チャット利用状況（chat_usage_events）を prompt_name ごとに集計する
-- 内部向けMCPツール get_chat_usage_metrics 用
--
-- prompt_name の例:
--   bill-chat-system-* … 議案ページのAIチャット
--   interview-chat / interview-summary / interview-initial-question … AIインタビュー
-- p_bill_id は metadata->>'billId' でのフィルタ。議案チャットとインタビュー系は
-- billId を記録するが、トップページチャット（top-chat-system）は記録しないため、
-- 指定時はトップチャットのイベントは対象外になる。
--
-- occurred_at / metadata->>'billId' へのインデックスは意図的に追加していない:
-- 全期間集計はどのみち全件スキャンが必要で（実測: 15万行で約170ms）、
-- 低頻度の内部ツールのためにイベント挿入（ホットパス）へ恒常的な
-- インデックス維持コストを載せる方が高くつくため。ダッシュボード等から
-- 定常的に呼ぶようになったら occurred_at 単独インデックスの追加を検討する。
create or replace function public.get_chat_usage_metrics(
  p_from timestamptz default null,
  p_to timestamptz default null,
  p_bill_id uuid default null
)
returns table (
  prompt_name text,
  event_count bigint,
  unique_user_count bigint,
  unique_session_count bigint,
  total_tokens bigint,
  total_cost_usd numeric
)
language sql
stable
as $$
  select
    coalesce(e.prompt_name, '(unknown)') as prompt_name,
    count(*) as event_count,
    count(distinct e.user_id) as unique_user_count,
    count(distinct e.session_id) as unique_session_count,
    coalesce(sum(e.total_tokens), 0)::bigint as total_tokens,
    coalesce(sum(e.cost_usd), 0) as total_cost_usd
  from public.chat_usage_events e
  where (p_from is null or e.occurred_at >= p_from)
    and (p_to is null or e.occurred_at < p_to)
    and (p_bill_id is null or e.metadata ->> 'billId' = p_bill_id::text)
  group by 1
  order by event_count desc;
$$;

revoke execute on function public.get_chat_usage_metrics(timestamptz, timestamptz, uuid) from public;
revoke execute on function public.get_chat_usage_metrics(timestamptz, timestamptz, uuid) from anon;
revoke execute on function public.get_chat_usage_metrics(timestamptz, timestamptz, uuid) from authenticated;
grant execute on function public.get_chat_usage_metrics(timestamptz, timestamptz, uuid) to service_role;
-- 公開データ取得API（オープンデータ）用の基盤
-- 1. api_rate_limits: 固定ウィンドウ方式のレートリミットカウンタ
-- 2. increment_api_rate_limit(): カウンタを原子的に加算し、制限内かを返す
-- 3. find_open_data_interview_reports(): 二次利用許諾済み公開レポートをキーセットページネーションで返す

-- ── レートリミットカウンタ ──────────────────────────────
CREATE TABLE api_rate_limits (
  key TEXT NOT NULL,
  window_start TIMESTAMPTZ NOT NULL,
  request_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (key, window_start)
);

ALTER TABLE api_rate_limits ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE api_rate_limits IS '公開APIのレートリミットカウンタ（固定ウィンドウ）。keyは "ip:<addr>" や "global" 等の制限単位';

CREATE OR REPLACE FUNCTION increment_api_rate_limit(
  p_key TEXT,
  p_window_start TIMESTAMPTZ,
  p_limit INTEGER
) RETURNS BOOLEAN
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  INSERT INTO api_rate_limits (key, window_start, request_count)
  VALUES (p_key, p_window_start, 1)
  ON CONFLICT (key, window_start)
  DO UPDATE SET request_count = api_rate_limits.request_count + 1
  RETURNING request_count INTO v_count;

  -- 過去ウィンドウを掃除（テーブル肥大を防ぐ）。
  -- 新しいウィンドウ行を作った最初の呼び出しのみ実行し、同一ウィンドウ内の
  -- 残り N-1 回の呼び出しで無駄な索引スキャンを繰り返さない
  IF v_count = 1 THEN
    -- 同一キーの過去ウィンドウ
    DELETE FROM api_rate_limits
    WHERE key = p_key AND window_start < p_window_start;
    -- 二度と現れないキー（IPローテーション等）の行が永久に残らないよう、
    -- 全キー横断で1時間より古いウィンドウも併せて掃除する
    DELETE FROM api_rate_limits
    WHERE window_start < p_window_start - INTERVAL '1 hour';
  END IF;

  RETURN v_count <= p_limit;
END;
$$;

-- 時間ベースの掃除（上記の全キー横断 DELETE）用
CREATE INDEX idx_api_rate_limits_window_start
  ON api_rate_limits (window_start);

COMMENT ON FUNCTION increment_api_rate_limit(TEXT, TIMESTAMPTZ, INTEGER) IS
  'レートリミットカウンタを加算し、制限内なら true を返す（超過時 false）。ウィンドウ開始時刻はアプリ側で切り捨て計算して渡す';

-- ── 公開データ取得 ──────────────────────────────────────
-- 対象: ユーザー公開同意 × 管理者公開 × 二次利用許諾（is_data_reuse_consented）
--       かつ 公開済み議案、かつ web と同じ k-匿名性ゲート
--       （議案あたり公開レポート数 >= p_min_public_reports）を満たすもの。
-- 並び: created_at DESC, id DESC のキーセットページネーション。
CREATE OR REPLACE FUNCTION find_open_data_interview_reports(
  p_min_public_reports INTEGER,
  p_limit INTEGER,
  p_cursor_created_at TIMESTAMPTZ DEFAULT NULL,
  p_cursor_id UUID DEFAULT NULL
) RETURNS TABLE (
  report_id UUID,
  bill_id UUID,
  bill_name TEXT,
  stance TEXT,
  role TEXT,
  role_title TEXT,
  role_description TEXT,
  summary TEXT,
  opinions JSONB,
  interview_session_id UUID,
  created_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  WITH eligible_bills AS (
    SELECT c.bill_id
    FROM interview_report r
    JOIN interview_sessions s ON s.id = r.interview_session_id
    JOIN interview_configs c ON c.id = s.interview_config_id
    JOIN bills b ON b.id = c.bill_id
    WHERE r.is_public_by_admin
      AND r.is_public_by_user
      AND b.publish_status = 'published'
    GROUP BY c.bill_id
    HAVING COUNT(*) >= p_min_public_reports
  )
  SELECT
    r.id AS report_id,
    c.bill_id,
    b.name AS bill_name,
    r.stance::TEXT,
    r.role::TEXT,
    r.role_title,
    r.role_description,
    r.summary,
    r.opinions,
    r.interview_session_id,
    r.created_at
  FROM interview_report r
  JOIN interview_sessions s ON s.id = r.interview_session_id
  JOIN interview_configs c ON c.id = s.interview_config_id
  JOIN bills b ON b.id = c.bill_id
  WHERE c.bill_id IN (SELECT eligible_bills.bill_id FROM eligible_bills)
    AND r.is_public_by_admin
    AND r.is_public_by_user
    AND r.is_data_reuse_consented
    AND (
      p_cursor_created_at IS NULL
      OR (r.created_at, r.id) < (p_cursor_created_at, p_cursor_id)
    )
  ORDER BY r.created_at DESC, r.id DESC
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION find_open_data_interview_reports(INTEGER, INTEGER, TIMESTAMPTZ, UUID) IS
  '公開データAPI用: 二次利用許諾済みの公開レポートを新しい順に返す。議案あたり公開レポート数が閾値未満の議案は除外（webのk-匿名性ゲートと同一基準）';

-- 公開データAPIのフィルタ用（is_data_reuse_consented での絞り込みを高速化）
CREATE INDEX idx_interview_report_data_reuse_public
  ON interview_report (created_at DESC, id DESC)
  WHERE is_public_by_admin AND is_public_by_user AND is_data_reuse_consented;

-- k-匿名性ゲート（eligible_bills CTE）の集計用。二次利用許諾を条件に含めない
-- 公開レポート集計のため、上の部分インデックスでは代替できない
CREATE INDEX idx_interview_report_public_session
  ON interview_report (interview_session_id)
  WHERE is_public_by_admin AND is_public_by_user;
-- Supabase CLI v2.106.0 以降でのローカル開発権限エラーへの対応 (#878)
--
-- CLI v2.106.0 の breaking change により `[api].auto_expose_new_tables` が
-- 未設定時 false となり、ローカルの start / db reset で public スキーマの
-- オブジェクトへの Data API 権限（anon / authenticated / service_role への
-- 自動 GRANT）が付与されなくなった。
-- そのため `pnpm db:reset` 後の `pnpm seed`（secret key = service_role）が
-- "permission denied for table tags" で失敗する。
--
-- 公式が案内する恒久対応は「アクセスすべきロールへ明示的に GRANT する」こと。
-- 本プロジェクトの public スキーマへのアクセスは全てサーバーサイド
-- （secret key = service_role）経由のため（AGENTS.md「RLSとアクセスパターン」）、
-- service_role のみに付与し、anon / authenticated / public からは明示的に
-- REVOKE して deny-by-default を権限レイヤーでも保証する。
-- （GRANT は他ロールの既存権限を削除しないため、旧仕様で自動付与された
--   環境に残る anon / authenticated への権限はここで明示的に取り除く）

-- 既存オブジェクト: anon / authenticated / public から取り除く
revoke all on all tables in schema public from public, anon, authenticated;
revoke all on all sequences in schema public from public, anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;

-- 既存オブジェクト: service_role へ付与
grant usage on schema public to service_role;
grant all on all tables in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

-- 今後のマイグレーション（postgres ロールで実行）で作成されるオブジェクト:
-- anon / authenticated / public への自動付与を止め、service_role のみ自動付与
alter default privileges in schema public revoke all on tables from public, anon, authenticated;
alter default privileges in schema public revoke all on sequences from public, anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;
alter default privileges in schema public grant all on tables to service_role;
alter default privileges in schema public grant all on sequences to service_role;
alter default privileges in schema public grant execute on functions to service_role;

-- 例外: is_admin() は storage.objects の RLS ポリシー評価（サムネイル
-- アップロード時に authenticated として実行）とクライアントからの RPC で
-- anon / authenticated からも実行されるため、EXECUTE を再付与する
-- （tests/supabase/db-function/is-admin.test.ts が この挙動を検証している）
grant execute on function public.is_admin() to anon, authenticated;
-- 管理者がレポートを非公開にした判断を記録するカラム。
-- これまで is_public_by_admin = false は「まだ公開されていない」と
-- 「管理者が非公開にした」を区別できず、ユーザー操作（レポートの公開設定変更）に
-- 伴う自動公開が管理者の非公開判断を上書きできてしまっていた。
-- NULL = 管理者による非公開操作なし（従来どおり自動公開の対象）。
ALTER TABLE interview_report
  ADD COLUMN admin_unpublished_at TIMESTAMPTZ;

COMMENT ON COLUMN interview_report.admin_unpublished_at IS '管理者がレポートを非公開にした時刻（NULL=管理者による非公開操作なし）。NULL でない場合はユーザー操作による自動公開の対象外';

-- 既存データの移行:
-- 論理削除済みインタビュー設定の配下レポートは unpublish_reports_by_config_id で
-- 公開停止済み（未公開のものも公開対象外）のため、管理者判断として記録する。
-- is_public_by_admin は変更しないため、現在の公開状態は変わらない。
UPDATE interview_report r
SET admin_unpublished_at = now()
FROM interview_sessions s
JOIN interview_configs c ON c.id = s.interview_config_id
WHERE r.interview_session_id = s.id
  AND c.deleted_at IS NOT NULL
  AND r.admin_unpublished_at IS NULL;

-- 設定の論理削除に伴う一括公開停止でも管理者判断を記録する。
-- 併せて、まだ公開されていないレポートにも記録を残し、論理削除済み設定配下の
-- レポートがユーザー操作で公開されることを防ぐ。
create or replace function unpublish_reports_by_config_id(p_config_id uuid)
returns void
language sql
as $$
  update interview_report r
  set is_public_by_admin = false,
      admin_unpublished_at = now()
  from interview_sessions s
  where r.interview_session_id = s.id
    and s.interview_config_id = p_config_id
    and (r.is_public_by_admin = true or r.admin_unpublished_at is null);
$$;
-- 政務調査向け分析のための意見タグ。
-- 「専門家の意見だけを見る」絞り込みは interview_report.role では成立しない
-- （role=subject_expert は自己申告ベースで全意見の1%未満しか付かない）。
-- 発言の根拠（reasoning_types）を意見単位で持つことで、肩書ではなく
-- 「職業・専門分野の知見に基づく発言」で絞り込めるようにする。
-- concern / proposal は懸念一覧・具体提案一覧の表示に使う。

ALTER TABLE interview_opinion
  ADD COLUMN concern TEXT,
  ADD COLUMN proposal TEXT,
  ADD COLUMN reasoning_types TEXT[] NOT NULL DEFAULT '{}',
  ADD COLUMN tags_extracted_at TIMESTAMPTZ;

COMMENT ON COLUMN interview_opinion.concern IS
  '意見が示す懸念の要点（20-50字）。懸念でなければ NULL';
COMMENT ON COLUMN interview_opinion.proposal IS
  '意見が示す具体的な提案・要望の要点（20-50字）。提案でなければ NULL';
COMMENT ON COLUMN interview_opinion.reasoning_types IS
  '発言の根拠の種類（personal_experience / family_observation / professional_expertise / research_reference / overseas_example / intuition / none）。専門家フィルタは professional_expertise の包含で判定する。「未抽出」は tags_extracted_at IS NULL が表すため、本列は NOT NULL DEFAULT {} とし空配列と NULL を区別しない';
COMMENT ON COLUMN interview_opinion.tags_extracted_at IS
  'タグ（concern/proposal/reasoning_types）を抽出した時刻。NULL=未抽出（タグバックフィルの対象）';

-- タグ未抽出の意見を引くための部分インデックス（バックフィルの対象抽出）
CREATE INDEX idx_interview_opinion_tags_pending
  ON interview_opinion (interview_report_id)
  WHERE tags_extracted_at IS NULL;

-- reasoning_types の包含検索（専門家フィルタ）用
CREATE INDEX idx_interview_opinion_reasoning_types
  ON interview_opinion USING GIN (reasoning_types);
-- トピックの2階層化。
--
-- 1議案で数十件のトピックが並列に並ぶと、論点の網羅チェックに使うリストとして読めない。
-- 大トピックで畳んでから中トピックを見る形にする。
--
-- 大トピック = 子を持つトピック。中トピック（葉）= 子を持たないトピック。
-- 「親が NULL かどうか」ではなく「子を持つかどうか」で判定すること。
-- 本マイグレーション以前の version は全トピックが親も子も持たないため、
-- この規則なら旧データはすべて葉として扱われる（後方互換）。
--
-- 意見が紐づくのは葉だけ。大トピックの件数は配下の合計として読み出し側が算出する
-- （同じ意見を親子で二重に持つと集計がずれるため）。

ALTER TABLE topic
  ADD COLUMN parent_topic_id UUID;

-- 別 version のトピックを親にできないよう複合FKで縛る。
-- topic_opinion が同じ理由で (version_id, id) への複合FKを使っている
-- （20260609150000_enforce_topic_opinion_same_version.sql）のに合わせる。
ALTER TABLE topic
  ADD CONSTRAINT topic_parent_same_version_fkey
  FOREIGN KEY (version_id, parent_topic_id)
  REFERENCES topic (version_id, id)
  ON DELETE CASCADE;

COMMENT ON COLUMN topic.parent_topic_id IS
  '親トピック（大トピック）。同一 version 内のみ参照可。NULL=大トピックまたは旧データの葉。「大トピックか」は子の有無で判定する';

CREATE INDEX idx_topic_parent ON topic (parent_topic_id);

-- グルーピング工程（group）を current_step に追加した。
COMMENT ON COLUMN topic_analysis_version.current_step IS
  '実行中のステップ: extract | merge | assign | group | done';
-- オープンデータAPIの議案一覧が使うキーセットページネーション
-- （publish_status = 'published' かつ created_at DESC, id DESC）用のインデックス
create index if not exists idx_bills_publish_status_created_at_id
  on bills (publish_status, created_at desc, id desc);
-- 議案ごとの公開レポート件数をまとめて数える。
--
-- 法案一覧では議案ごとに回答数バッジを出すため、議案数ぶんの count クエリを
-- 並べると一覧の表示で数十回叩くことになる。1クエリで済むようにDB側で集約する。
-- 公開の定義は countPublicReportsByBillId と同じ（管理者公開 × ユーザー公開）。
--
-- count(id) ではなく count(*) にする。where 句が idx_interview_report_public_session
-- の述語と一致するので、id を読まなければ index only scan に載る。
-- interview_report.interview_session_id は UNIQUE で join が行を増やさないため、
-- count(*) と count(id) は同義。
create or replace function public.count_public_reports_by_bill_ids(p_bill_ids uuid[])
returns table (
  bill_id uuid,
  report_count bigint
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    c.bill_id,
    count(*) as report_count
  from interview_report r
  join interview_sessions s on s.id = r.interview_session_id
  join interview_configs c on c.id = s.interview_config_id
  where c.bill_id = any(p_bill_ids)
    and r.is_public_by_admin
    and r.is_public_by_user
  group by c.bill_id;
$$;

comment on function public.count_public_reports_by_bill_ids(uuid[]) is
  '議案ごとの公開レポート件数（管理者公開 × ユーザー公開）をまとめて返す。法案一覧の回答数バッジ用。';
-- インタビュー設定ごとのプロンプト上書きを保持する。
--
-- 既定のプロンプトはコード側（packages/shared/src/interview-prompts）に置いたままで、
-- ここには管理画面で編集された節だけを入れる。null または空オブジェクトなら全て既定値。
-- 節を増減させるたびにマイグレーションを打たずに済むよう jsonb で持つ。
-- 受け付けるキーはアプリ側の zod スキーマで検証する。
alter table interview_configs
  add column prompt_overrides jsonb;

comment on column interview_configs.prompt_overrides is
  'インタビュープロンプトの節ごとの上書き。キーは PROMPT_SECTION_KEYS（responsibilities / cautions / expertiseDetection / deepDiveTechniques / stopCriteria / questionUsageRules）。未設定の節はコード側の既定値を使う。';
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
COMMIT;
