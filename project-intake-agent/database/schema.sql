-- Project Intake Agent database schema
-- PostgreSQL / Supabase compatible

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS project_intake_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    intake_page_id TEXT NOT NULL UNIQUE,
    project_page_id TEXT,
    status TEXT NOT NULL DEFAULT 'New project',
    raw_intake JSONB NOT NULL,
    normalized_context JSONB,
    ai_plan JSONB,
    error_message TEXT,
    last_failed_workflow TEXT,
    last_failed_node TEXT,
    last_error_at TIMESTAMPTZ,
    error_count INTEGER DEFAULT 0,
    retry_count INTEGER DEFAULT 0,
    last_execution_id TEXT,
    last_workflow_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS project_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id UUID REFERENCES project_intake_runs(run_id) ON DELETE CASCADE,
    project_page_id TEXT,
    file_name TEXT,
    file_type TEXT,
    mime TEXT,
    source_url TEXT,
    storage_url TEXT,
    storage_bucket TEXT,
    storage_path TEXT,
    notion_document_page_id TEXT,
    notion_file_upload_id TEXT,
    upload_status TEXT,
    extracted_text TEXT,
    text_length INTEGER DEFAULT 0,
    processing_status TEXT DEFAULT 'processed',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_run_file UNIQUE (run_id, file_name, file_type)
);

CREATE TABLE IF NOT EXISTS project_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    run_id UUID REFERENCES project_intake_runs(run_id) ON DELETE CASCADE,
    project_page_id TEXT,
    notion_task_id TEXT,
    task_key TEXT UNIQUE,
    task_name TEXT NOT NULL,
    task_description TEXT,
    task_stage TEXT,
    task_status TEXT DEFAULT 'Not started',
    priority TEXT DEFAULT 'Medium',
    effort_level TEXT DEFAULT 'Medium',
    deadline DATE,
    task_order INTEGER,
    created_in_notion BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS project_events (
    id BIGSERIAL PRIMARY KEY,
    run_id UUID,
    event_type TEXT NOT NULL,
    workflow_name TEXT,
    node_name TEXT,
    severity TEXT,
    message TEXT,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_intake_runs_status ON project_intake_runs(status);
CREATE INDEX IF NOT EXISTS idx_project_intake_runs_intake_page ON project_intake_runs(intake_page_id);
CREATE INDEX IF NOT EXISTS idx_project_documents_run_id ON project_documents(run_id);
CREATE INDEX IF NOT EXISTS idx_project_tasks_run_id ON project_tasks(run_id);
CREATE INDEX IF NOT EXISTS idx_project_events_run_id ON project_events(run_id);
CREATE INDEX IF NOT EXISTS idx_project_events_created_at ON project_events(created_at);
