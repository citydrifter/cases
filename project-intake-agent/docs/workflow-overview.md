# Workflow Inventory

| Workflow | Purpose |
|---|---|
| 00 - Error Handler | Receives n8n Error Trigger payloads, logs errors, updates run error state, and sends Telegram alerts. |
| 01 - Intake Router | Detects new Notion intake submissions, reserves a run, creates a Notion project, and starts processing. |
| 02 - Attachment Processor | Extracts SOP/documentation/screenshot URLs, processes files, calls the asset uploader, and saves document rows. |
| 03 - Asset Uploader | Uploads files to Supabase Storage and attaches them to the Notion Document Hub. |
| 04 - Context Builder | Loads intake and document records, creates normalized_context, and saves it to PostgreSQL. |
| 05 - AI Planner | Generates structured project plans and project_tasks rows. |
| 06 - Notion Writer | Updates the Notion project and creates linked task records in Notion. |

## Workflow files

### `00-error-handler.json`

- n8n name: `00 - Error Handler`
- Nodes: 8
- Key nodes: Error Trigger, Normalize Error Payload, Critical Error?, Update Run Error State, Send Telegram Alert, Find Recent Active Run, Build Error Context, Insert Error Event

### `01-intake-router.json`

- n8n name: `01 - Intake Router`
- Nodes: 12
- Key nodes: Notion Trigger, If, notion_project_create, Message a model, Prepare Attachment Processor Input, Call 'Attachment Processor', Reserve Run, Prepare Router Input, Needs Project?, Update Run With Project ID

### `02-attachment-processor.json`

- n8n name: `02 - Attachment Processor`
- Nodes: 28
- Key nodes: When Executed by Another Workflow, Extract Attachment Items, Mark Run INGESTING_FILES, Has Attachments?, No Files Placeholder, Switch by File Type, Convert PDF to Text, Prepare PDF Document Row, Download DOCX, DOCX to Text

### `03-asset-uploader.json`

- n8n name: `03 - Asset Uploader`
- Nodes: 9
- Key nodes: When Executed by Another Workflow, Normalize Upload Input, Create Document Hub Page, Download File, Create Notion Upload Request, Ingest Doc to Supabase, Add Doc File to Doc Page, Upload Doc to Notion, Return Upload Metadata

### `04-context-builder.json`

- n8n name: `04 - Context Builder`
- Nodes: 7
- Key nodes: When Executed by Another Workflow, Standardize Context, Load Run Context, Limit AI Context, Save Normalized Context, Prepare AI Planner Input, Call 'AI Planner'

### `05-ai-planner.json`

- n8n name: `05 - AI Planner`
- Nodes: 11
- Key nodes: When Executed by Another Workflow, Prepare Planner Prompt, AI Agent, Groq Chat Model, Parse AI Plan, Build Task Rows, Save AI Plan, Prepare Notion Writer Input, Insert Task Row, Call '06 - Notion Writer'

### `06-notion-writer.json`

- n8n name: `06 - Notion Writer`
- Nodes: 13
- Key nodes: When Executed by Another Workflow, Load Writer Context, Prepare Project Update, Update Notion Project, Load Pending Task Rows, Build Notion Task Items, Has Pending Tasks?, Create Notion Task, Save Notion Task ID, Mark Run Completed

