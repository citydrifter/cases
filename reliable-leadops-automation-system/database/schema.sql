-- Reliable LeadOps Automation System
-- PostgreSQL schema

CREATE TABLE IF NOT EXISTS raw_events (
    internal_id serial PRIMARY KEY,

    external_id text UNIQUE NOT NULL,
    payload jsonb NOT NULL,
    event_source text NOT NULL,

    processing_status text NOT NULL DEFAULT 'processing',
    error_message text,

    retry_count int DEFAULT 0,
    last_retry_at timestamp,
    next_retry_at timestamp,
    manual_review_reason text,

    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),
    processed_at timestamp,

    CONSTRAINT raw_events_processing_status_check
    CHECK (
        processing_status IN (
            'processing',
            'completed',
            'failed',
            'retrying',
            'manual_review',
            'duplicate_lead'
        )
    )
);

CREATE TABLE IF NOT EXISTS leads (
    internal_id serial PRIMARY KEY,

    external_id text UNIQUE,
    event_id int NOT NULL REFERENCES raw_events(internal_id),

    lead_name text,
    lead_email text NOT NULL UNIQUE,
    lead_phone text,
    lead_source text,

    status text NOT NULL DEFAULT 'new',

    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now()
);

CREATE TABLE IF NOT EXISTS workflow_logs (
    internal_id serial PRIMARY KEY,

    event_id int REFERENCES raw_events(internal_id),
    lead_id int REFERENCES leads(internal_id),

    step_name text NOT NULL,
    status text NOT NULL,
    wf_message text,

    created_at timestamp DEFAULT now(),

    CONSTRAINT workflow_logs_status_check
    CHECK (
        status IN (
            'started',
            'success',
            'failed',
            'skipped'
        )
    )
);