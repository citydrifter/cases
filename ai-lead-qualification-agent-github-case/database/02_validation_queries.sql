SELECT internal_id, external_id, event_source, processing_status, created_at, updated_at
FROM public.raw_events
ORDER BY updated_at DESC
LIMIT 10;

SELECT internal_id, external_id, event_id, lead_name, lead_email, lead_source, status, created_at, updated_at
FROM public.leads
ORDER BY updated_at DESC
LIMIT 10;

SELECT
    internal_id,
    external_id,
    processing_status,
    payload -> 'normalized_lead' AS normalized_lead,
    payload -> 'deduplication' AS deduplication,
    payload -> 'lead_context_enrichment' AS lead_context_enrichment,
    payload -> 'lead_score' AS lead_score,
    payload -> 'crm_sync' AS crm_sync,
    payload -> 'follow_up' AS follow_up
FROM public.raw_events
WHERE internal_id = 17;

SELECT internal_id, event_id, lead_id, step_name, status, wf_message, workflow_name, created_at
FROM public.workflow_logs
ORDER BY created_at DESC
LIMIT 30;

SELECT
    l.internal_id AS lead_id,
    l.lead_name,
    l.lead_email,
    l.status,
    l.event_id,
    r.internal_id AS raw_event_id,
    r.external_id,
    r.processing_status
FROM public.leads l
LEFT JOIN public.raw_events r ON r.internal_id = l.event_id
ORDER BY l.updated_at DESC
LIMIT 10;
