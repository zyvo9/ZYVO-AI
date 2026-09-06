
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
