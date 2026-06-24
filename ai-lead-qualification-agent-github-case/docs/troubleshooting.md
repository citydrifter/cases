# Troubleshooting

## `relation workflow_logs does not exist`

Use `public.workflow_logs` and verify n8n connects to the same database.

## Foreign key violation: `leads_event_id_fkey`

Workflow 02 received an event ID that does not exist in `raw_events`. Use a real `raw_events.internal_id`.

## Foreign key violation: `workflow_logs_lead_id_fkey`

Logging is using a stale or fake lead ID. Use canonical `leads.internal_id` and FK-safe log inserts.

## Wrong lead ID in CRM Writer

Resolve canonical lead ID from email, valid incoming lead ID, `raw_events.payload.lead_id`, or `raw_events.payload.deduplication.lead_id`.

## Notion null value error

Sanitize Notion payload before create/update. Omit empty email, phone, URL, relation, and date fields.

## Invalid n8n expression syntax

Build complex Telegram messages in a Code node, then use `={{ $json.telegram_message }}` in the Telegram node.
