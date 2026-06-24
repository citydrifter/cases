# Architecture

The Project Intake Agent is a modular n8n automation system for converting Notion intake submissions into structured project plans and Notion task records.

## High-level flow

```mermaid
flowchart TD
    A[Notion Intake Form] --> B[01 - Intake Router]
    B --> C[PostgreSQL: project_intake_runs]
    B --> D[Notion Project Page]
    B --> E[02 - Attachment Processor]
    E --> F[03 - Asset Uploader]
    F --> G[Supabase Storage]
    F --> H[Notion Document Hub]
    E --> I[PostgreSQL: project_documents]
    E --> J[04 - Context Builder]
    J --> K[PostgreSQL: normalized_context]
    J --> L[05 - AI Planner]
    L --> M[PostgreSQL: ai_plan + project_tasks]
    L --> N[06 - Notion Writer]
    N --> O[Notion Tasks Database]
    N --> P[PostgreSQL: notion_task_id]
    Q[00 - Error Handler] --> R[PostgreSQL: project_events]
    Q --> S[Telegram Alert]
```

## Core design choices

- The workflow is split into reusable modules instead of one monolithic n8n canvas.
- PostgreSQL stores run state, document rows, AI plans, task rows, and error events.
- Notion remains the human-facing workspace for project pages, documents, and tasks.
- Supabase Storage is used for durable uploaded file storage.
- The AI Planner is guarded by parsing and normalization logic before tasks are saved.
- Missing inputs are converted into a Discovery task instead of blocking the workflow.
