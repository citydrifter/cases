# Architecture

The system follows a modular workflow chain.

```text
Webhook Lead Source
    ↓
01 - Lead Intake Router
    ↓
02 - Lead Deduplication Resolver
    ↓
03 - Lead Context Enrichment
    ↓
04 - AI Lead Scorer
    ↓
05 - CRM Writer
    ↓
06 - Follow-up Creator
```

## State Layer

- `raw_events` stores the run/event.
- `leads` stores canonical lead identity.
- `workflow_logs` stores audit logs.

## AI Layer

AI is used for enrichment, scoring, and follow-up planning. Every AI output is parsed and normalized before storage or action.

## CRM Layer

Notion is used as a lightweight CRM. CRM sync metadata is stored in `raw_events.payload.crm_sync`.

## Monitoring Layer

The global error handler uses n8n Error Trigger and Telegram.
