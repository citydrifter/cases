# Workflow Overview

## 00 - Lead Error Handler
Receives failed execution payloads from n8n Error Trigger. Resolves the event using `last_execution_id`, updates `raw_events` error fields, writes a workflow log, and sends Telegram alert.

## 01 - Lead Intake Router
Receives webhook leads, normalizes payloads, reserves `raw_events`, registers execution ID, and calls deduplication.

## 02 - Lead Deduplication Resolver
Upserts into `leads` by email or external ID. Saves canonical `lead_id` to `raw_events.payload`.

## 03 - Lead Context Enrichment
Fetches website if available, builds person/company/request context, enriches with AI, and saves `lead_context_enrichment`.

## 04 - AI Lead Scorer
Scores the lead, normalizes status/priority/fit, updates `leads.status`, and saves `lead_score`.

## 05 - CRM Writer
Creates or updates Notion CRM page. Sanitizes null Notion values. Saves `crm_sync`.

## 06 - Follow-up Creator
Generates follow-up task, creates Notion follow-up item if needed, updates raw event to completed, and sends Telegram alert for qualified/high-priority leads.
