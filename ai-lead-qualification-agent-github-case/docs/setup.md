# Setup

## 1. Database

Run `database/01_compatible_patches.sql`.

## 2. n8n Credentials

Configure PostgreSQL, Notion API, Telegram Bot, and your AI model provider.

## 3. Notion Databases

Create or configure Leads CRM and Sales Follow-up Tasks. See `docs/notion-crm-schema.md`.

## 4. Workflow Import

This repository includes workflow manuals. Place sanitized n8n JSON exports in `workflows/`.

## 5. Error Workflow

Set `00 - Lead Error Handler` as the error workflow for all six business workflows.

## 6. Test

Use payloads from `payloads/`.
