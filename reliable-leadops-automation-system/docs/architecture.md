# Architecture

## Overview

The Reliable LeadOps Automation System is a workflow-based integration system built with n8n and PostgreSQL.

The system is designed to process inbound lead submissions reliably, not only through the happy path, but also through duplicate detection, error handling, retry processing, manual review, and monitoring.

## System Components

The system contains four workflows:

1. Lead Intake Pipeline
2. Failed Event Retry & Manual Review Pipeline
3. Manual Review Resolve Workflow
4. Daily LeadOps Monitoring Report

## High-Level Architecture

flowchart TD
    FORM[Website Form Payload] --> INTAKE[Lead Intake Pipeline]

    INTAKE --> DB[(PostgreSQL)]
    INTAKE --> CRM[Mock CRM]
    INTAKE --> TG[Telegram Notifications]

    DB --> RETRY[Failed Event Retry & Manual Review Pipeline]
    RETRY --> CRM
    RETRY --> TG

    TG --> MANUAL[Manual Review Resolve Workflow]
    MANUAL --> DB

    DB --> MONITORING[Daily LeadOps Monitoring Report]
    MONITORING --> TG
Layers
Workflow Orchestration Layer

n8n controls the execution flow, branching, retries, CRM calls, notifications, and scheduled reports.

State Management Layer

PostgreSQL stores raw events, leads, retry metadata, and workflow logs.

Reliability Layer

The system uses idempotency, deduplication, retry scheduling, and manual review escalation.

Observability Layer

Workflow logs, Telegram notifications, and daily monitoring reports provide operational visibility.

Human Operations Layer

Manual review allows a human operator to inspect problematic events and return them to the retry queue.

# Event Lifecycle

The main state is stored in `raw_events.processing_status`.

## Statuses

| Status | Meaning |
|---|---|
| `processing` | Event has been received and processing started |
| `completed` | Event was successfully processed and lead was created |
| `failed` | Event failed during processing and can be retried |
| `retrying` | Retry workflow is currently processing the event |
| `manual_review` | Event requires human review |
| `duplicate_lead` | Event was processed, but lead already exists |

## State Diagram

stateDiagram-v2
    [*] --> processing

    processing --> completed: CRM lead created
    processing --> failed: CRM/API failure
    processing --> manual_review: invalid payload
    processing --> duplicate_lead: lead email already exists

    failed --> retrying: retry workflow starts
    retrying --> completed: retry success
    retrying --> failed: retry failed
    failed --> manual_review: retry limit reached

    manual_review --> failed: manager returns event to retry queue

    completed --> [*]
    duplicate_lead --> [*]
Important Rule

completed should only be set after the lead has actually been created or resolved by the normal processing path.

Manual review does not directly mark an event as completed. Instead, it returns the event to the retry queue.


# Reliability Patterns

This project focuses on reliability patterns for workflow automation.

## Idempotency

Incoming events are checked by `external_id` before processing.

This prevents the same form submission from being processed multiple times.

## Lead Deduplication

Leads are checked by normalized email before CRM creation.

The `leads.lead_email` column also has a unique constraint to prevent duplicate local records.

## Raw Event Storage

Every incoming payload is stored in `raw_events.payload` as JSONB.

This allows:

- debugging
- replay
- retry
- manual inspection
- event reconstruction

## State Management

`raw_events.processing_status` acts as the source of truth for event lifecycle state.

n8n executes the process, but PostgreSQL remembers the state.

## Retry Scheduling

Failed events use:

- `retry_count`
- `last_retry_at`
- `next_retry_at`

The retry workflow only picks events that are eligible for retry.

## Manual Review

Invalid or unresolved events move to `manual_review`.

A human can inspect the raw payload and return the event to the retry queue through the Manual Review Resolve workflow.

## Observability

Every important step is written to `workflow_logs`.

Examples:

- `raw_event_inserted`
- `crm_lead_created`
- `retry_started`
- `retry_success`
- `retry_failed`
- `manual_review_required`
- `notification_sent`

## Alerting

Telegram notifications are used for:

- new lead creation
- CRM failure
- manual review required
- daily monitoring report

## Monitoring

The monitoring workflow aggregates operational metrics from PostgreSQL and sends a daily report.

Metrics include:

- total events
- completed events
- failed events
- manual review events
- duplicate leads
- failure rate
- top lead sources
- retry statistics
- recent problem events