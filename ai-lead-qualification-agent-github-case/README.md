# AI Lead Qualification & CRM Enrichment Agent

A modular n8n automation system that receives inbound B2B leads, normalizes and deduplicates them, enriches lead and company context, scores sales fit with AI, writes structured CRM records into Notion, creates follow-up tasks, sends Telegram alerts for qualified opportunities, and records execution state in PostgreSQL.

This repository is structured as a production-style automation case study. It demonstrates how a revenue operations process can be split into small reusable workflows with durable state, idempotent database writes, AI-assisted qualification, CRM synchronization, follow-up task automation, and centralized error handling.

---

## Case Summary

Inbound leads often arrive with incomplete or inconsistent information. Sales and RevOps teams usually need to manually check whether the lead is real, deduplicate it against existing CRM data, research the company, understand the buyer’s intent, decide whether it is worth pursuing, assign priority, create CRM records, and generate follow-up tasks.

The **AI Lead Qualification & CRM Enrichment Agent** automates that process.

It takes a raw lead submission and turns it into:

- a normalized lead record;
- a deduplicated PostgreSQL identity;
- an enriched person/company/intent profile;
- a structured AI lead score;
- a Notion CRM page;
- a follow-up task;
- a Telegram sales alert for qualified leads;
- a full workflow audit trail.

---

## Business Problem

Sales teams lose time when inbound leads require manual review before action. Common issues include duplicate submissions, incomplete form fields, unclear buying intent, missing company context, manual CRM entry, inconsistent scoring, delayed follow-up, and no reliable audit trail across automation steps.

This case solves those problems by using PostgreSQL as a state layer and n8n as a workflow orchestration layer. AI is used only where interpretation is useful: enrichment, intent analysis, scoring, and follow-up drafting.

---

## What the System Does

1. Receives a new lead from a webhook/form payload.
2. Normalizes names, email, phone, source, company, domain, website, message, budget, timeline, and UTM data.
3. Reserves or updates a durable event in `raw_events`.
4. Deduplicates the lead by email or external source ID.
5. Upserts the lead into `leads`.
6. Fetches the company website if available.
7. Builds a lead context object combining person, company, request, website, and source metadata.
8. Uses AI to enrich the lead context.
9. Uses AI to score lead quality and qualification status.
10. Updates the raw event with enrichment and scoring data.
11. Creates or updates the lead in Notion CRM.
12. Creates a follow-up task when appropriate.
13. Sends a Telegram alert for qualified or high-priority leads.
14. Logs workflow activity and errors.
15. Marks the event completed.

---

## Repository Structure

```text
.
├── database/
│   ├── 00_existing_schema_notes.sql
│   ├── 01_compatible_patches.sql
│   └── 02_validation_queries.sql
├── docs/
│   ├── ai-prompts.md
│   ├── architecture.md
│   ├── error-handling.md
│   ├── notion-crm-schema.md
│   ├── setup.md
│   ├── testing.md
│   ├── troubleshooting.md
│   └── workflow-overview.md
├── payloads/
├── screenshots/
├── workflow-manuals/
├── workflows/
├── .env.example
└── README.md
```

---

## Architecture

```text
Lead Webhook
    │
    ▼
01 - Lead Intake Router
    │
    ▼
02 - Lead Deduplication Resolver
    │
    ▼
03 - Lead Context Enrichment
    │
    ▼
04 - AI Lead Scorer
    │
    ▼
05 - CRM Writer
    │
    ▼
06 - Follow-up Creator
```

A global error handler is configured separately:

```text
Any workflow failure
    │
    ▼
00 - Lead Error Handler
    │
    ├── resolves event context
    ├── updates raw_events error state
    ├── inserts workflow log
    └── sends Telegram alert
```

---

## Workflow Modules

### 00 - Lead Error Handler

Global n8n Error Trigger workflow. It receives failed execution payloads, resolves the related `raw_events.internal_id` using n8n execution metadata, updates error state, inserts a workflow log, and sends Telegram notification.

### 01 - Lead Intake Router

Receives a webhook payload, normalizes lead fields, builds a stable external ID, reserves or updates a row in `raw_events`, registers execution ID for error tracing, logs the intake step, and calls deduplication.

### 02 - Lead Deduplication Resolver

Deduplicates and persists the lead identity. It upserts by email when email exists and falls back to external ID when email is missing. It stores canonical `leads.internal_id` in `raw_events.payload`.

### 03 - Lead Context Enrichment

Enriches the whole lead context, not only the company. It combines person details, company metadata, request message, budget/timeline, optional website text, and source data. AI generates person/company/intent/routing context.

### 04 - AI Lead Scorer

Scores the enriched lead, normalizes status/priority/fit, applies deterministic safety rules, updates `leads.status`, and saves `lead_score` into `raw_events.payload`.

### 05 - CRM Writer

Creates or updates a Notion CRM page. It resolves canonical `leads.internal_id`, sanitizes null values, avoids sending unsafe Notion properties, writes CRM sync metadata, and calls follow-up creation.

### 06 - Follow-up Creator

Generates follow-up plan, creates a Notion follow-up task when needed, marks the raw event completed, and sends Telegram alert for qualified or high-priority leads.

---

## Data Model

This case reuses an existing database schema instead of creating a new isolated schema.

### `raw_events`

Used as the run/event state table. It stores the evolving lead payload:

```json
{
  "raw_payload": {},
  "normalized_lead": {},
  "lead_id": 41,
  "deduplication": {},
  "lead_context_enrichment": {},
  "lead_score": {},
  "crm_sync": {},
  "follow_up": {}
}
```

### `leads`

Canonical lead identity table. `leads.internal_id` is the canonical ID used by downstream workflows.

### `workflow_logs`

Workflow audit trail. Inserts are intentionally non-critical; a logging error should not stop CRM writing or follow-up creation.

---

## Idempotency

The system supports reruns through stable `raw_events.external_id`, email-based lead upsert, canonical lead IDs, saved Notion CRM page IDs, CRM update logic, and follow-up metadata stored in the raw event payload.

---

## AI Controls

AI output is parsed and normalized before storage or action. Prompts require raw JSON, avoid markdown, use allowed values, and include deterministic fallback logic for scoring and status.

---

## Error Handling

Each workflow registers `last_execution_id` and `last_workflow_name` in `raw_events`. If a workflow fails, the global Error Handler uses the n8n Error Trigger payload to resolve the event, mark it failed, log the error, and send Telegram notification.

---

## Notion CRM

Recommended Notion CRM properties:

```text
Lead name       title
Email           email
Phone           phone
Status          select
Priority        select
Lead Score      number
Fit Level       select
Company         rich_text
Domain          rich_text
Website         url
Job Title       rich_text
Source          select
Routing Team    select
Next Action     rich_text
Notes           rich_text
```

---

## Security Notes

Before publishing, remove real Notion database IDs, Telegram chat IDs, API tokens, personal emails, phone numbers, private n8n execution URLs, and real customer data.

---

## Why This Case Matters

This case demonstrates a practical revenue operations automation system. It is not a simple AI prompt demo. It combines workflow orchestration, database state, deduplication, AI enrichment, deterministic validation, CRM writing, follow-up automation, and production monitoring.
