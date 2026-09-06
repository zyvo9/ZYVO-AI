# Zyvo Memory

This file is Zyvo's persistent memory. It loads automatically at the start
of every session, on every device where it is deployed. Keep it short
(under ~150 lines), factual, and organized — it is part of your context.

## How to maintain this file (rules for you, the agent)

- When the user shares lasting info (name, job, projects, preferences,
  devices, recurring needs) or says "remember this" / "mone rakho" —
  UPDATE this file immediately with the edit tool. Don't ask permission.
- Put every entry under the right section below. Merge duplicates.
  Delete anything stale. Never store passwords/tokens/keys here.
- The user speaks Banglish (Bangla in Latin letters) — reply in Banglish
  unless they switch languages.
- Keep this file under 150 lines. If it grows, summarize old entries.

## User

- (empty yet)

## Preferences

- (empty yet)

## Projects

- (empty yet)

## Devices & Environment

- Primary device: Android phone, Zyvo runs in Termux
- Models come from the user's own OmniRoute endpoint

## Notes

- (empty yet)

## Codebase memory (zyvo)

When working inside ANY project directory (a folder that looks like a
codebase — has src/, package.json, .git, etc.):

- First time: explore it (README, entry points, structure), then CREATE
  `<project>/AGENTS.md` with: what the project is, architecture/key files,
  run/build/test commands, decisions (dated), current state.
- After significant work: update that file (new features, renames,
  decisions). Don't wait to be asked.
- Future sessions auto-load it — never re-explain the codebase from scratch.
- The user's own instructions in that file are sacred — keep them intact.
- Keep it under ~120 lines, facts only, no secrets.
- If asked "what does this project do" / "kothay change korsilam" — answer
  from memory first, verify against code, then fix drift.
