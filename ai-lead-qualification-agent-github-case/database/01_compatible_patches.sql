-- Safe compatible patches for AI Lead Qualification case.
-- Additive only.

ALTER TABLE public.raw_events
ADD COLUMN IF NOT EXISTS last_execution_id TEXT,
ADD COLUMN IF NOT EXISTS last_workflow_name TEXT,
ADD COLUMN IF NOT EXISTS error_message TEXT,
ADD COLUMN IF NOT EXISTS last_failed_workflow TEXT,
ADD COLUMN IF NOT EXISTS last_failed_node TEXT,
ADD COLUMN IF NOT EXISTS last_error_at TIMESTAMP WITHOUT TIME ZONE,
ADD COLUMN IF NOT EXISTS error_count INTEGER DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_raw_events_last_execution_id
ON public.raw_events(last_execution_id);

CREATE INDEX IF NOT EXISTS idx_raw_events_processing_status
ON public.raw_events(processing_status);

CREATE INDEX IF NOT EXISTS idx_raw_events_external_id
ON public.raw_events(external_id);

CREATE INDEX IF NOT EXISTS idx_leads_email_lower
ON public.leads(LOWER(lead_email))
WHERE lead_email IS NOT NULL;
