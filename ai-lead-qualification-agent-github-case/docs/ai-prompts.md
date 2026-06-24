# AI Prompt Schemas

## Enrichment Output

```json
{
  "person": {},
  "company": {},
  "intent": {},
  "routing_context": {}
}
```

## Lead Score Output

```json
{
  "lead_score": 0,
  "fit_level": "Low",
  "priority": "Low",
  "routing_team": "Sales",
  "lead_status": "qualified",
  "recommended_next_action": "",
  "reasoning_summary": "",
  "positive_signals": [],
  "negative_signals": [],
  "missing_information": []
}
```

## Follow-up Output

```json
{
  "should_create_follow_up": true,
  "follow_up_type": "sales_discovery",
  "task_title": "",
  "task_description": "",
  "task_priority": "Medium",
  "due_in_days": 1,
  "draft_message": "",
  "telegram_summary": ""
}
```
