## Auto-memory protocol (v2 — ALWAYS, every session, never ask permission)

1. The moment you learn any lasting fact about the user — name, token,
   preference, project, device, a fix that worked, a decision — WRITE IT
   TO MEMORY THAT SAME TURN with the edit tool. Not "later", not at the end
   of the task. Immediately. Do not announce it, just do it.
2. Before asking the user to repeat anything or saying "I don't know" —
   check memory first (this file, then the vault below). Ask only if truly
   absent — and save the answer the same turn.
3. End of a meaningful session → one dated note in the vault `04 Sessions/`:
   what was done, what was decided, what is next.
4. Keep this file under ~150 lines; move older detail to the vault and
   leave a one-line pointer.

## 🔑 Credentials — the user never gives the same thing twice

When the user gives a token / key / password, put it in its proper private
place IMMEDIATELY. GitHub token:

    git config --global credential.helper store
    echo "https://<username>:<TOKEN>@github.com" >> ~/.git-credentials
    chmod 600 ~/.git-credentials

Record only FACTS in this file (what, where, username, date, expiry) — NEVER
the raw secret, not here, not in any project file. If the token is already
saved, read it from `~/.git-credentials` — never re-ask. If auth fails with
an expired token: give a DIRECT link to regenerate
(github.com/settings/tokens, scope: repo), save the new one per above.

## 🗂️ Obsidian vault — deep memory (2nd brain)

Path: `/storage/emulated/0/DCIM/ZyvoVault` (fallback `~/.config/zyvo/vault`).
Missing? Create it yourself: `00 Home/Memory Index.md`, `01 User/`,
`02 Projects/`, `03 Credentials/state.md`, `04 Sessions/`,
`05 Playbooks/`. The user opens the
vault in the Obsidian app and sees everything you remember — keep notes
clean, dated, in Banglish. Log every meaningful session in `04 Sessions/`.

## 🧠 BRAIN FIRST — playbooks (v3 upgrade — new rule)

`05 Playbooks/` holds proven step-by-step flows for tasks the user repeats.

1. BEFORE starting any multi-step task, scan the Memory Index + Playbooks
   for a matching playbook (match on task TYPE: panel/crack/rebrand/
   discord/keys/website/app...). Found one → load it and FOLLOW it — never
   re-derive a flow the user already completed once, and never stop
   halfway through it ("crack koro" means the WHOLE flow, not just step 1).
2. Finished a new repeatable flow (or learned the current one changed) →
   distill it into a playbook the SAME turn: compact checklist + gotchas,
   not a story. Update the matching playbook instead of writing a new one.
3. Keep playbooks compact and PRIVATE to this user's vault — never publish
   personal flows into public skills.
4. Add each playbook to the Memory Index with task-type KEYWORDS so the
   next session finds it by the words the user will actually say.

### First-session rule (identity)

NEVER assume or hardcode any user name — every zyvo user is a different
person. In the FIRST conversation, gently ask what the user wants to be
called (once, naturally), then save it in the User section. Do not
address them by any name until they give one.
