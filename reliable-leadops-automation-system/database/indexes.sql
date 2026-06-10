-- Indexes for Reliable LeadOps Automation System

-- raw_events.external_id already has a unique index from UNIQUE constraint.
-- leads.lead_email already has a unique index from UNIQUE constraint.

CREATE INDEX IF NOT EXISTS idx_raw_events_processing_status
ON raw_events(processing_status);

CREATE INDEX IF NOT EXISTS idx_raw_events_created_at
ON raw_events(created_at);

CREATE INDEX IF NOT EXISTS idx_raw_events_next_retry_at
ON raw_events(next_retry_at);

CREATE INDEX IF NOT EXISTS idx_raw_events_retry_status
ON raw_events(processing_status, retry_count, next_retry_at);

CREATE INDEX IF NOT EXISTS idx_workflow_logs_event_id
ON workflow_logs(event_id);

CREATE INDEX IF NOT EXISTS idx_workflow_logs_step_name
ON workflow_logs(step_name);

CREATE INDEX IF NOT EXISTS idx_workflow_logs_created_at
ON workflow_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_leads_created_at
ON leads(created_at);

CREATE INDEX IF NOT EXISTS idx_leads_lead_source
ON leads(lead_source);