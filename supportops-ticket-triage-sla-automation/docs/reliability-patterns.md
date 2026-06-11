# Reliability Patterns

## Overview

This project demonstrates reliability patterns for workflow automation and SupportOps systems.

The goal is to move beyond simple task automation and design a system that is traceable, observable, recoverable, and auditable.

---

## Raw Event Storage

Incoming ClickUp payloads are stored in `raw_events.payload` as JSONB.

This allows the system to preserve the original event exactly as it was received.

Benefits:

- debugging
- replay
- recovery
- auditability
- manual inspection
- validation failure analysis

Example:

```text
ClickUp task payload → raw_events.payload
```

---

## Event Processing State

The field `raw_events.processing_status` tracks technical processing state.

Examples:

- `processing`
- `completed`
- `manual_review`
- `failed`

This is separate from ticket status.

Ticket status is stored in:

```text
tickets.status
```

This separation keeps technical event processing and business lifecycle state independent.

---

## Deduplication

Incoming ClickUp events are checked by external task ID.

The external ClickUp task ID is stored as:

```text
raw_events.external_id
tickets.external_id
```

This prevents duplicate processing if the same task event is received multiple times.

Example duplicate scenario:

```text
ClickUp sends same task payload twice
→ system detects existing raw_event
→ processing is skipped
→ duplicate event log is written
```

---

## Database-Backed State Management

PostgreSQL stores structured automation state.

The system does not rely only on transient n8n execution data.

PostgreSQL stores:

- raw event payloads
- ticket records
- ticket status
- SLA deadlines
- SLA warning timestamps
- escalation timestamps
- first response timestamps
- resolution timestamps
- workflow logs
- ticket logs

This makes the system observable and recoverable.

---

## SLA Warning and Escalation State

The system uses two fields to prevent repeated notifications and repeated escalations.

| Field | Purpose |
|---|---|
| `sla_warning_sent_at` | Prevents duplicate SLA warnings |
| `escalated_at` | Prevents duplicate escalations |

This is important because the SLA Monitoring workflow runs repeatedly on schedule.

Without these fields, the system could send the same warning or escalation alert multiple times.

---

## Status Transition Validation

ClickUp status updates are not blindly written to PostgreSQL.

The ClickUp Ticket Status Sync workflow:

1. receives ClickUp task update event
2. detects whether it is a status change
3. normalizes the ClickUp status
4. finds the local ticket
5. validates allowed transition
6. updates local ticket status only if transition is allowed

This protects the database from invalid lifecycle states.

---

## Status Normalization

ClickUp status names can differ from internal status names.

Examples:

| ClickUp Status | Internal Status |
|---|---|
| `new` | `open` |
| `to do` | `open` |
| `in progress` | `in_progress` |
| `waiting for customer` | `waiting_customer` |
| `done` | `resolved` |
| `completed` | `closed` |

This allows the workflow to support flexible ClickUp naming while keeping PostgreSQL values consistent.

---

## Audit Logging

The system separates technical logs from business logs.

### workflow_logs

Technical automation history.

It answers:

```text
What did the automation do?
Which workflow step ran?
Did it succeed, fail, or skip?
```

Examples:

- `raw_event_inserted`
- `ticket_created`
- `sla_warning_sent`
- `sla_breach_detected`
- `clickup_status_synced`

### ticket_logs

Business-level ticket history.

It answers:

```text
What happened to the ticket?
Which status changed?
Who changed it?
```

Examples:

- `ticket_created`
- `status_changed`
- `status_synced_from_clickup`
- `sla_warning_sent`

---

## Operational Alerting

Telegram is used for operational visibility.

Notifications are sent for:

- new ticket triage
- invalid ticket payload
- SLA warning
- SLA breach
- ClickUp status sync
- rejected status transition
- local ticket not found during sync

Telegram is not the source of truth. It is an alerting channel.

The source of truth for state and history is PostgreSQL.

---

## Manual Review

Invalid incoming ticket payloads are moved to manual review.

Example:

```text
missing requester email
→ raw_event created
→ processing_status = manual_review
→ error_message = Validation failed: missing_requester_email
```

This prevents bad data from being silently discarded.

---

## ClickUp as Operational Workspace

ClickUp remains the tool where agents work with support tickets.

Agents can:

- view tickets
- change task statuses
- manage operational work

The system syncs important ClickUp changes into PostgreSQL for auditability, reporting, and automation logic.

---

## PostgreSQL as Reliability Layer

PostgreSQL acts as the reliability layer.

It stores:

- what happened
- when it happened
- what state the system is in
- what needs attention
- what has already been notified or escalated

This makes the system more reliable than a workflow that only passes data from one SaaS tool to another.

---

## Production Improvements

Potential improvements for production:

- parameterized SQL queries
- webhook signature verification
- retry logic for failed API calls
- dead-letter queue for invalid events
- business-hours-aware SLA calculation
- role-based transition validation
- better incident dashboarding
- automatic stuck-ticket detection
- centralized secrets management