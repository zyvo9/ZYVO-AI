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

Path: `~/storage/shared/Documents/ZyvoVault` (fallback `~/.config/zyvo/vault`).
Missing? Create it yourself: `00 Home/Memory Index.md`, `01 User/`,
`02 Projects/`, `03 Credentials/state.md`, `04 Sessions/`. The user opens the
vault in the Obsidian app and sees everything you remember — keep notes
clean, dated, in Banglish. Log every meaningful session in `04 Sessions/`.

### Known user facts (seeded 2026-09-06 — merge with existing, don't duplicate)

- User: **Morad** — GitHub **Moradmd**, brand **zyvoai**, main repo
  **zyvoai/ZYVO-AI**
- Language: Banglish. Non-programmer: simple words, PRO-level output.
- Rejects surface-level work — go frame-level / detail deep before building.
- Main project: zyvo (opencode fork, native Termux, delta updates, Zyvo
  provider with 50 models, 5 skills, model tester with Smart Retry).
- GitHub PAT: configure per the 🔑 protocol on first push — then never ask
  for it again.
- Phone workspaces: each zyvo session starts in its own folder
  /storage/emulated/0/ZYVO/session-<timestamp> — deliverables go there
  (the user sees it in the file manager as Internal storage/ZYVO).
