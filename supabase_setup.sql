-- ============================================================
-- Carrystar Schedule — Supabase Setup SQL
-- Run this in: Supabase → SQL Editor → New Query → Run
-- ============================================================

-- 1. Weekly schedule data (one row per week)
CREATE TABLE IF NOT EXISTS schedule_weeks (
  week_iso    TEXT PRIMARY KEY,           -- Monday ISO date e.g. '2026-05-04'
  data        JSONB NOT NULL DEFAULT '{}',-- full schedule for that week
  updated_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_by  TEXT DEFAULT 'unknown'      -- editor's email
);

-- 2. App-wide config (roster, shift presets, settings, etc.)
CREATE TABLE IF NOT EXISTS app_config (
  key        TEXT PRIMARY KEY,            -- 'roster', 'shiftPresets', 'savedReports', 'sundayActive', 'settings'
  value      JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Row Level Security ──────────────────────────────────────
ALTER TABLE schedule_weeks ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config     ENABLE ROW LEVEL SECURITY;

-- Anyone (including the public URL) can READ
CREATE POLICY "Public read schedule_weeks"
  ON schedule_weeks FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Public read app_config"
  ON app_config FOR SELECT
  TO anon, authenticated
  USING (true);

-- Only logged-in users can WRITE
CREATE POLICY "Auth insert schedule_weeks"
  ON schedule_weeks FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Auth update schedule_weeks"
  ON schedule_weeks FOR UPDATE
  TO authenticated
  USING (true) WITH CHECK (true);

CREATE POLICY "Auth insert app_config"
  ON app_config FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Auth update app_config"
  ON app_config FOR UPDATE
  TO authenticated
  USING (true) WITH CHECK (true);

-- ── Enable real-time for live sync ─────────────────────────
-- (Supabase Dashboard → Database → Replication → enable both tables)
-- Or run:
ALTER PUBLICATION supabase_realtime ADD TABLE schedule_weeks;
ALTER PUBLICATION supabase_realtime ADD TABLE app_config;

-- ── Done ───────────────────────────────────────────────────
-- Next: go to Authentication → Users → Add User
-- Create accounts for Eduardo, Jose, and anyone else who needs edit access.
