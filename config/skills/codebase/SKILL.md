---
name: codebase
description: Project codebase memory — maintain an AGENTS.md memory file inside any project you work on, recording architecture, key files, commands, decisions and progress. Future sessions start with full context, no re-exploration. Use when starting work in any project directory, or when the user asks you to remember/learn their codebase.
---

# Codebase Memory

Every project you work on gets a living memory file: `<project>/AGENTS.md`.
It loads AUTOMATICALLY at the start of every future session in that
directory — so you (and the user) never re-explain the codebase again.

## When to create/update it

- **First time in a project:** explore the codebase (README, entry points,
  folder structure, config files), then CREATE the memory file with real,
  specific content.
- **After significant work:** new feature, renamed files, changed
  architecture, new commands, important decision — UPDATE the relevant
  section immediately. Don't wait to be asked.
- The user's own instructions in AGENTS.md (if any) are SACRED — never
  delete or rewrite their content. Append/integrate your memory around it.

## Memory file structure

```markdown
# <Project Name>

## What this is
2-3 lines: what the project does, for whom.

## Architecture
- entry point: src/index.ts (x)
- key folders: src/api (HTTP), src/tools (agent tools)
- data flow: request -> server -> service -> db

## Commands
- run: bun run dev
- test: bun test
- build: bun run script/build.ts

## Conventions
- Effect-ts style services, schema validation at edges
- Banglish comments in docs, English in code

## Decisions
- 2026-09-05: chose SQLite over Postgres (single-user, local-first)

## Current state
- working: auth flow, session list
- next: file upload feature
```

## Rules

1. Keep it under ~120 lines. It loads in every session — dead weight is
   poison. Summarize ruthlessly.
2. Facts only: paths, names, commands, decisions, gotchas. Nofluff.
3. Update DECISIONS with a date. Update "Current state" as work completes.
4. Never store tokens/passwords/keys — not even "hidden" ones.
5. If the project already has AGENTS.md with the user's own instructions,
   keep those lines untouched at the top and add a `## Zyvo memory`
   section below with your structure.
6. If the user asks "what does this project do" / "kothay change korsi" —
   answer FROM this memory first, verify against the code, then fix the
   memory if it drifted.

## Anti-patterns (never do these)

- Copying entire file contents into memory (paths + one-line purpose is enough)
- Vague entries ("some config files exist")
- Storing session transcripts or chat history
- Editing memory instead of doing the actual task the user asked for
