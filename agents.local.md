# agents.local.md

Local-only agent coordination rules for this machine.

## Project Identity

- project_name: AiVectra
- mailbox_root: /tmp/codex/agent-bus
- requests_dir: /tmp/codex/agent-bus/requests
- responses_dir: /tmp/codex/agent-bus/responses
- locks_dir: /tmp/codex/agent-bus/locks
- archive_dir: /tmp/codex/agent-bus/archive
- persistent_mailbox_root: /Users/toddhenderson/.codex/agent-bus

## Purpose

This file defines local cross-project mailbox behavior between AiVectra and AiLang.
It is local workflow guidance only. It does not define language semantics.

## Mailbox Storage Rules

- `/tmp/codex/agent-bus/` is the canonical active runtime mailbox.
- `/Users/toddhenderson/.codex/agent-bus/` is the persistent mirror.
- `/tmp/codex/agent-bus/` is volatile and may disappear at any time.
- On every write to `/tmp/codex/agent-bus/`, update the matching file under `/Users/toddhenderson/.codex/agent-bus/` when permissions allow.
- On startup, if both mailbox trees exist, prefer the newer file by modification time and copy it to the other location so both remain synchronized.
- If only one mailbox tree exists, use it as the source of truth and recreate the missing counterpart.
- If the persistent mailbox is not writable, continue using `/tmp/codex/agent-bus/` and report degraded persistence sync.
- Keep file names and directory structure identical between both mailbox trees.

## Allowed Message Types

- task
- question
- review_request
- reply
- status

## Mailbox File Format

Use TOML files only.

Required fields:

- id
- from
- to
- type
- status
- reply_to
- created_utc
- cwd
- summary
- body

Optional fields:

- priority
- expires_utc
- related_branch
- related_pr
- related_commit

## AiVectra Responsibilities

AiVectra may:

- send requests to AiLang about VM/task semantics, deterministic event ownership, syscall contracts, and concurrency boundaries
- answer requests from AiLang about UI host integration, event delivery into the owner thread, host-side worker coordination, and responsive UI constraints
- summarize mailbox replies into the active Codex thread

AiVectra must not:

- invent concurrency semantics that belong to AiLang/AiVM
- bypass the AiVM event queue model through mailbox instructions
- directly edit AiLang through mailbox protocol

## Claim Rules

When processing a mailbox request addressed to AiVectra:

1. Verify to = "AiVectra".
2. Refuse files missing required fields.
3. Claim work by creating a lock file in locks/ named <id>.lock.
4. If lock already exists, skip.
5. Write reply as a new TOML file in responses/.
6. Move processed request to archive/ or update status to done.

## Response Rules

- Preserve original id.
- Set reply_to to the source message id.
- Keep responses concise and implementation-focused.
- State integration risks explicitly.
- If blocked, return status = "failed" with a concrete reason.

## Retention

- Archive completed request/response files.
- Do not delete mailbox history immediately.
- Prefer append-only operational history.

## Safety

- Local-only workflow.
- No secrets in mailbox files.
- No live agent-to-agent chat assumptions.
- Mailbox files are the only cross-project coordination surface.
