# Setup

## 1. Create n8n credentials

Create credentials for:

- Notion API
- PostgreSQL / Supabase Postgres
- Supabase API
- Groq API
- Ollama, if using the local project creation model
- PDF.co, if using PDF.co for PDF extraction
- Telegram Bot API

## 2. Prepare PostgreSQL

Run:

```sql
-- from database/schema.sql
```

## 3. Configure Notion databases

Required Notion databases:

- Project Intake Form
- Projects
- Tasks
- Document Hub

Allowed Project Status values:

- New project
- Not started
- Discovery
- Design
- Development
- Testing
- Production
- Done

## 4. Import workflows

Import the files from `workflows/` in this order:

1. `00-error-handler.json`
2. `03-asset-uploader.json`
3. `02-attachment-processor.json`
4. `04-context-builder.json`
5. `05-ai-planner.json`
6. `06-notion-writer.json`
7. `01-intake-router.json`

Reconnect credentials and replace placeholder IDs such as `YOUR_NOTION_PROJECTS_DB_ID` and `YOUR_TELEGRAM_CHAT_ID`.

## 5. Configure error workflow

Set `00 - Error Handler` as the error workflow for each production workflow.

## 6. Test order

1. Test `03 - Asset Uploader` with one file URL.
2. Test `02 - Attachment Processor` with one PDF, one DOCX, and one screenshot.
3. Test `04 - Context Builder` for normalized context.
4. Test `05 - AI Planner` for task rows.
5. Test `06 - Notion Writer` for task creation.
6. Test `01 - Intake Router` end-to-end.
