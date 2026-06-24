# Notion CRM Schema

## Leads CRM

| Property | Type |
|---|---|
| Lead name | title |
| Email | email |
| Phone | phone |
| Status | select |
| Priority | select |
| Lead Score | number |
| Fit Level | select |
| Company | rich_text |
| Domain | rich_text |
| Website | url |
| Job Title | rich_text |
| Source | select |
| Routing Team | select |
| Next Action | rich_text |
| Notes | rich_text |

## Sales Follow-up Tasks

| Property | Type |
|---|---|
| Task name | title |
| Lead | relation to Leads CRM |
| Status | select |
| Priority | select |
| Due Date | date |
| Owner Role | rich_text |
| Task Type | select |
| Draft Message | rich_text |
| Description | rich_text |
