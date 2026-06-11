# Testing Scenarios

## Overview

This document describes test scenarios for the Customer Support Ticket Triage & SLA Automation System.

The goal is to verify that all major workflows work correctly:

1. Ticket Intake & Triage Pipeline
2. SLA Monitoring & Escalation Pipeline
3. ClickUp Ticket Status Sync

---

## 1. Ticket Intake Happy Path

### Input

Submit a valid ClickUp support form payload.

Example:

```text
cu_support_00001
Payment failed but invoice was generated
Requester Email: laura.adams@example.com
Product: Billing Portal
```

### Expected Result

`raw_events`:

```text
external_id = cu_support_00001
event_source = clickup_support_form
processing_status = completed
```

`tickets`:

```text
external_id = cu_support_00001
category = billing
priority = high
status = open
assigned_team = Billing
assigned_to = alice.support@example.com
sla_due_at is populated
```

`ticket_logs`:

```text
ticket_created
```

`workflow_logs`:

```text
raw_event_inserted
ticket_created
notification_sent
event_completed
```

---

## 2. Technical Urgent Ticket

### Input

Submit a payload with a technical outage.

Example:

```text
cu_support_00002
Production webhook integration is down
```

### Expected Result

`tickets`:

```text
category = technical
priority = urgent
assigned_team = Technical
assigned_to = bob.technical@example.com
```

SLA should use urgent policy:

```text
response_time_minutes = 30
```

---

## 3. Account Access Urgent Ticket

### Input

Submit a payload with an account access issue.

Example:

```text
cu_support_00003
Cannot access admin account
```

### Expected Result

`tickets`:

```text
category = account
priority = urgent
assigned_team = Customer Success
assigned_to = clara.success@example.com
```

---

## 4. Feature Request Low Priority

### Input

Submit a feature request.

Example:

```text
cu_support_00004
Feature request: export dashboard as PDF
```

### Expected Result

`tickets`:

```text
category = feature_request
priority = low
assigned_team = Customer Success
assigned_to = clara.success@example.com
```

---

## 5. Invalid Payload

### Input

Submit a payload with missing requester email.

Example:

```text
cu_support_00005
Requester Email is empty
```

### Expected Result

`raw_events`:

```text
processing_status = manual_review
error_message = Validation failed: missing_requester_email
manual_review_reason = Invalid support ticket payload: missing_requester_email
```

`tickets`:

```text
No ticket should be created.
```

`workflow_logs`:

```text
validation_failed
```

---

## 6. Duplicate Event

### Input

Submit the same ClickUp task ID twice.

Example:

```text
cu_support_00001 submitted twice
```

### Expected Result

The second execution should not create another ticket.

`tickets`:

```sql
SELECT COUNT(*)
FROM tickets
WHERE external_id = 'cu_support_00001';
```

Expected count:

```text
1
```

`workflow_logs` should contain:

```text
duplicate_event_check
status = skipped
```

---

## 7. SLA Warning

### Setup

Set a ticket SLA deadline into the near future.

```sql
UPDATE tickets
SET sla_due_at = NOW() + INTERVAL '10 minutes',
    sla_warning_sent_at = NULL,
    escalated_at = NULL,
    status = 'open',
    updated_at = NOW()
WHERE external_id = 'cu_support_00002';
```

### Expected Result

After running SLA Monitoring workflow:

`tickets`:

```text
sla_warning_sent_at is populated
status remains open
escalated_at remains null
```

`ticket_logs`:

```text
sla_warning_sent
```

`workflow_logs`:

```text
sla_warning_sent
status = success
```

Telegram:

```text
SLA warning notification is sent.
```

---

## 8. SLA Breach

### Setup

Set a ticket SLA deadline into the past.

```sql
UPDATE tickets
SET sla_due_at = NOW() - INTERVAL '5 minutes',
    sla_warning_sent_at = NULL,
    escalated_at = NULL,
    status = 'open',
    updated_at = NOW()
WHERE external_id = 'cu_support_00003';
```

### Expected Result

After running SLA Monitoring workflow:

`tickets`:

```text
status = escalated
escalated_at is populated
```

`ticket_logs`:

```text
status_changed
old_value = open
new_value = escalated
```

`workflow_logs`:

```text
sla_breach_detected
```

Telegram:

```text
SLA breached notification is sent.
```

---

## 9. ClickUp Status Sync: Open to In Progress

### Input

Simulate ClickUp status change:

```text
open → in_progress
```

### Expected Result

`tickets`:

```text
status = in_progress
first_response_at is populated
resolved_at remains null
```

`ticket_logs`:

```text
status_synced_from_clickup
old_value = open
new_value = in_progress
```

`workflow_logs`:

```text
clickup_status_synced
```

---

## 10. ClickUp Status Sync: In Progress to Resolved

### Input

Simulate ClickUp status change:

```text
in_progress → resolved
```

### Expected Result

`tickets`:

```text
status = resolved
resolved_at is populated
first_response_at remains unchanged
```

`ticket_logs`:

```text
status_synced_from_clickup
old_value = in_progress
new_value = resolved
```

---

## 11. ClickUp Status Sync: Resolved to Closed

### Input

Simulate ClickUp status change:

```text
resolved → closed
```

### Expected Result

`tickets`:

```text
status = closed
first_response_at remains unchanged
resolved_at remains unchanged
```

`ticket_logs`:

```text
status_synced_from_clickup
old_value = resolved
new_value = closed
```

---

## 12. Reopened Ticket

### Input

Simulate ClickUp status change:

```text
resolved → in_progress
```

### Expected Result

The transition is accepted as a reopen scenario.

`tickets`:

```text
status = in_progress
```

`ticket_logs`:

```text
status_synced_from_clickup
old_value = resolved
new_value = in_progress
```

---

## 13. Invalid Status Transition

### Input

Try to move a closed ticket back to in progress.

```text
closed → in_progress
```

### Expected Result

The transition is rejected.

`tickets`:

```text
status remains closed
```

Telegram:

```text
ClickUp status sync rejected
```

No ticket status update should be written.

---

## 14. Local Ticket Not Found

### Input

Send a ClickUp status update for a task that does not exist in PostgreSQL.

Example:

```text
task_id = cu_support_unknown
```

### Expected Result

Workflow should not update any ticket.

Telegram:

```text
ClickUp status sync skipped
Reason: local ticket not found
```

---

## Useful Verification Queries

### Check tickets

```sql
SELECT
    internal_id,
    external_id,
    status,
    category,
    priority,
    assigned_team,
    assigned_to,
    sla_due_at,
    sla_warning_sent_at,
    escalated_at,
    first_response_at,
    resolved_at,
    updated_at
FROM tickets
ORDER BY internal_id;
```

### Check ticket logs

```sql
SELECT
    ticket_id,
    action,
    old_value,
    new_value,
    actor_type,
    actor_name,
    message,
    created_at
FROM ticket_logs
ORDER BY internal_id DESC;
```

### Check workflow logs

```sql
SELECT
    workflow_name,
    ticket_id,
    step_name,
    status,
    wf_message,
    created_at
FROM workflow_logs
ORDER BY internal_id DESC;
```

---

## Expected Final Demo State

After full demo testing, the system should show:

```text
multiple tickets created
one invalid payload in manual_review
one or more SLA warnings
one or more escalated tickets
one ticket moved through open → in_progress → resolved → closed
ticket_logs showing business history
workflow_logs showing automation history
```