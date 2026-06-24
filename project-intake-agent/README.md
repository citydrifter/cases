# AI Project Intake Agent

A modular n8n automation system that converts a Notion project intake submission into a PostgreSQL-backed execution run, processes attached SOPs, documentation, and screenshots, builds normalized AI context, generates an implementation blueprint, upserts task records, creates linked Notion tasks, and sends Telegram alerts for failed executions.

This repository is structured as a portfolio-grade automation case study. It demonstrates how a complex business process can be split into reusable n8n workflows with durable state, idempotent database writes, file ingestion, AI planning, Notion database automation, and centralized production error handling.

---

## Overview

Many internal automation requests start as unstructured or semi-structured intake forms. A requester submits a short description, attaches SOPs or documentation, maybe adds screenshots, and expects an automation engineer to translate that information into a project plan.

In practice, this creates several operational problems:

- intake data is inconsistent across requests;
- SOPs and documentation are not analyzed systematically;
- screenshots often contain important process details but are ignored;
- project plans depend heavily on the person reviewing the request;
- task creation in Notion is manual and repetitive;
- reruns can create duplicate projects, documents, or tasks;
- errors are difficult to trace across multi-step workflow chains.

The AI Project Intake Agent solves this by treating each intake as a durable automation run. The system stores run state in PostgreSQL, processes uploaded context, generates an AI planning object, creates task records with stable keys, and writes the final project/task structure back to Notion.

---

## What the System Does

The system receives a new Notion intake page and turns it into an execution-ready project workspace.

At a high level, it performs the following steps:

1. Detects a new Notion project intake submission.
2. Reserves a unique run in PostgreSQL using the intake page ID.
3. Creates or links a Notion project page.
4. Extracts SOP, documentation, and screenshot attachments from the intake payload.
5. Processes PDFs, DOCX files, and images.
6. Uploads reusable assets to Supabase Storage and Notion Document Hub.
7. Stores extracted document text and upload metadata in PostgreSQL.
8. Builds a normalized context object for AI planning.
9. Generates a technical project blueprint with tasks.
10. Parses, validates, normalizes, and stores the AI plan.
11. Upserts task records into PostgreSQL using stable task keys.
12. Creates linked Notion task pages.
13. Persists Notion task IDs back to PostgreSQL for rerun safety.
14. Sends Telegram alerts if any workflow execution fails.

---

## Repository Structure

```text
.
├── database/
│   └── schema.sql
├── docs/
│   ├── architecture.md
│   ├── error-handling.md
│   ├── setup.md
│   └── workflow-overview.md
├── screenshots/
│   └── README.md
├── workflows/
│   ├── 00 - Error Handler.json
│   ├── 01 - Intake Router.json
│   ├── 02 - Attachment Processor.json
│   ├── 03 - Asset Uploader.json
│   ├── 04 - Context Builder.json
│   ├── 05 - AI Planner.json
│   └── 06 - Notion Writer.json
├── .env.example
└── README.md