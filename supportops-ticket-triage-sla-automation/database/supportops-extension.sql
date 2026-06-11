-- SupportOps Ticket Triage & SLA Automation
-- PostgreSQL extension for existing automation platform schema.
--
-- Existing shared tables:
-- - raw_events
-- - workflow_logs
--
-- Existing LeadOps domain table:
-- - leads
--
-- This file adds SupportOps domain tables:
-- - sla_policies
-- - tickets
-- - ticket_logs
-- - team_members
--
-- It also extends workflow_logs with ticket_id.

CREATE TABLE IF NOT EXISTS sla_policies (
    internal_id serial PRIMARY KEY,

    priority text NOT NULL UNIQUE,
    response_time_minutes int NOT NULL,
    resolution_time_minutes int,

    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),

    CONSTRAINT sla_policies_priority_check
    CHECK (
        priority IN (
            'low',
            'medium',
            'high',
            'urgent'
        )
    )
);

CREATE TABLE IF NOT EXISTS tickets (
    internal_id serial PRIMARY KEY,

    external_id text UNIQUE NOT NULL,
    event_id int NOT NULL REFERENCES raw_events(internal_id),

    requester_name text,
    requester_email text NOT NULL,
    requester_company text,

    subject text NOT NULL,
    message text NOT NULL,
    product text,

    category text,
    priority text NOT NULL DEFAULT 'medium',
    status text NOT NULL DEFAULT 'open',

    assigned_team text,
    assigned_to text,

    sla_policy_id int REFERENCES sla_policies(internal_id),
    sla_due_at timestamp,
    sla_warning_sent_at timestamp,
    escalated_at timestamp,

    first_response_at timestamp,
    resolved_at timestamp,

    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now(),

    CONSTRAINT tickets_priority_check
    CHECK (
        priority IN (
            'low',
            'medium',
            'high',
            'urgent'
        )
    ),

    CONSTRAINT tickets_status_check
    CHECK (
        status IN (
            'open',
            'in_progress',
            'waiting_customer',
            'resolved',
            'closed',
            'escalated'
        )
    )
);

CREATE TABLE IF NOT EXISTS ticket_logs (
    internal_id serial PRIMARY KEY,

    ticket_id int NOT NULL REFERENCES tickets(internal_id),

    action text NOT NULL,
    old_value text,
    new_value text,

    actor_type text NOT NULL DEFAULT 'system',
    actor_name text,
    message text,

    created_at timestamp DEFAULT now(),

    CONSTRAINT ticket_logs_actor_type_check
    CHECK (
        actor_type IN (
            'system',
            'agent',
            'customer',
            'manager'
        )
    )
);

CREATE TABLE IF NOT EXISTS team_members (
    internal_id serial PRIMARY KEY,

    member_name text NOT NULL,
    member_email text NOT NULL UNIQUE,
    team_name text NOT NULL,
    is_active boolean DEFAULT true,

    created_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now()
);

ALTER TABLE workflow_logs
ADD COLUMN IF NOT EXISTS ticket_id int REFERENCES tickets(internal_id);

CREATE INDEX IF NOT EXISTS idx_tickets_external_id
ON tickets(external_id);

CREATE INDEX IF NOT EXISTS idx_tickets_event_id
ON tickets(event_id);

CREATE INDEX IF NOT EXISTS idx_tickets_status
ON tickets(status);

CREATE INDEX IF NOT EXISTS idx_tickets_priority
ON tickets(priority);

CREATE INDEX IF NOT EXISTS idx_tickets_category
ON tickets(category);

CREATE INDEX IF NOT EXISTS idx_tickets_sla_due_at
ON tickets(sla_due_at);

CREATE INDEX IF NOT EXISTS idx_tickets_sla_warning_sent_at
ON tickets(sla_warning_sent_at);

CREATE INDEX IF NOT EXISTS idx_tickets_escalated_at
ON tickets(escalated_at);

CREATE INDEX IF NOT EXISTS idx_ticket_logs_ticket_id
ON ticket_logs(ticket_id);

CREATE INDEX IF NOT EXISTS idx_workflow_logs_ticket_id
ON workflow_logs(ticket_id);

INSERT INTO sla_policies (
    priority,
    response_time_minutes,
    resolution_time_minutes
)
VALUES
    ('low', 1440, 4320),
    ('medium', 480, 1440),
    ('high', 120, 480),
    ('urgent', 30, 240)
ON CONFLICT (priority) DO NOTHING;

INSERT INTO team_members (
    member_name,
    member_email,
    team_name
)
VALUES
    ('Alice Support', 'alice.support@example.com', 'Billing'),
    ('Bob Technical', 'bob.technical@example.com', 'Technical'),
    ('Clara Success', 'clara.success@example.com', 'Customer Success'),
    ('David Ops', 'david.ops@example.com', 'Operations')
ON CONFLICT (member_email) DO NOTHING;