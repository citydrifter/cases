# Error Handling

Every workflow registers its n8n execution ID in `raw_events` after it knows the event ID.

```sql
UPDATE public.raw_events
SET last_execution_id = $2,
    last_workflow_name = $3,
    updated_at = NOW()
WHERE internal_id = $1
RETURNING internal_id;
```

Parameters:

```js
[
  $json.event_id || $json.run_id,
  $execution.id,
  $workflow.name
]
```

Critical nodes should fail normally. Non-critical nodes such as website fetch and workflow log inserts can use `On Error → Continue`.
