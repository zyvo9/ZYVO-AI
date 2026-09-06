---
name: github
description: Work with GitHub repositories from the phone — clone any repo, read and understand the codebase, fix bugs, commit, push, create pull requests and manage issues via the gh CLI or the GitHub API. Use when the user wants to clone a repo, contribute to a project, fix a bug in an existing codebase, or manage GitHub PRs/issues.
---

# GitHub Power Workflows (clone, code, PR)

Work on REAL repositories from the phone: clone any repo, understand the
codebase, fix bugs, push changes and open pull requests. The phone only
handles text files — all heavy thinking is yours, all hosting is GitHub's.

## Requirements checklist (do this first)

- `git` and `gh` (GitHub CLI): `pkg install -y git gh`
- User's Personal Access Token (repo scope minimum, workflow scope if the
  repo has Actions files):
  https://github.com/settings/tokens/new?scopes=repo,workflow&description=Zyvo
- GitHub username

## One-time setup (per token)

```
pkg install -y gh
echo "<TOKEN>" | gh auth login --with-token
gh auth status
```
gh handles git credentials automatically after auth. (Alternatively use
`https://<TOKEN>@github.com/user/repo.git` remotes — never commit remotes
with tokens.)

## Clone a repo

```
gh repo clone <owner>/<repo>        # full
gh repo clone <owner>/<repo> -- --depth 1   # fast (big repos)
```
On phones prefer `--depth 1` (or `--filter=blob:none`) — much faster, less
storage. If the task needs history, deepen later with
`git fetch --unshallow`.

## Understand the codebase (before touching anything)

1. `ls` the top level, read README.md
2. Find the entry points (main/package.json scripts/index files)
3. Use grep (ripgrep `rg`) for the feature/bug area:
   `rg "functionName" --type ts -n`
4. Read only the relevant files. Summarize the architecture to the user
   in Banglish before making changes.

## Fix a bug / add a feature (the PR flow)

```
gh repo clone <owner>/<repo> -- --depth 1
cd <repo>
git checkout -b zyvo/<short-change-name>
# ...read code, make changes with edit tools...
git add -A
git commit -m "fix: <clear description>"
git push -u origin zyvo/<short-change-name>
gh pr create --title "<title>" --body "<what and why>"
```
Then give the user the PR link: `https://github.com/<owner>/<repo>/pull/<n>`

Rules:
- Small, focused changes. Never reformat unrelated code.
- Match the project's existing style (read neighboring code first).
- Commit message: `fix:`/`feat:`/`docs:` prefix, one clear line.

## Issues & PR management

```
gh issue list -R <owner>/<repo>
gh issue view <n> -R <owner>/<repo>
gh pr list -R <owner>/<repo>
gh pr view <n> -R <owner>/<repo>
gh pr create ... # after pushing a branch
gh pr checks <n> -R <owner>/<repo>
```

## Private repos

Use a token with repo scope: clone via
`https://<TOKEN>@github.com/<owner>/<repo>.git` or run
`gh auth login --with-token` first. Never store the token in files.

## Pitfalls

- Big repos: always `--depth 1` first; unshallow only if needed.
- Protected branches: push a branch and PR, never push directly to main.
- Fork workflow (open-source contributing): `gh repo fork --clone`, push
  to the fork, PR against upstream.
- gh not found: `pkg install -y gh`.
- If API rate-limits appear, the token is missing or expired — re-auth.
