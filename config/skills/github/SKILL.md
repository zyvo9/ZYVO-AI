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
  https://github.com/settings/tokens/new?scopes=repo,workflow,delete_repo,admin%3Arepo_hook,admin%3Aorg,admin%3Apublic_key,admin%3Agpg_key,notifications,project,user,gist,audit_log&description=Zyvo
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


## PRO UPGRADE PACK (repo management, review, releases, forks)

### Repo creation + setup (complete)
```
curl -s -X POST -H "Authorization: token <TOKEN>"   -d '{"name":"<repo>","description":"<real description>","private":false,"has_issues":true}'   https://api.github.com/user/repos
# add topics (discoverability):
curl -s -X PUT -H "Authorization: token <TOKEN>"   https://api.github.com/repos/<owner>/<repo>/topics   -d '{"names":["android","termux","zyvo"]}'
```

### Code review flow
```
gh pr diff <n> -R <owner>/<repo>          # see every changed line
gh pr checks <n> -R <owner>/<repo>        # CI status
gh pr review <n> -R <owner>/<repo> --comment --body "<feedback>"
gh pr merge <n> -R <owner>/<repo> --merge
```
Review rules: read the diff fully before commenting; comment on the
smallest fixable unit; suggest, don't demand.

### Releases with real notes
```
gh release create v1.0 -R <owner>/<repo> --title "v1.0" --notes "- first feature set"
gh release upload v1.0 ./app.apk -R <owner>/<repo>
```
Release notes format: what's new (bullets), known issues, download link.

### Fork contribution flow (open source projects)
```
gh repo fork <owner>/<repo> --clone
cd <repo> && git checkout -b zyvo/<change>
# ...make changes...
git push -u origin zyvo/<change>
gh pr create --head zyvo/<change> --base main -R <original-owner>/<repo>
```

### Sync a fork with upstream
```
git remote add upstream https://github.com/<owner>/<repo>.git
git fetch upstream && git merge upstream/main
```

### Rate limits & etiquette
- 5000 requests/hour with a token — plenty, but don't poll in loops
- One API call per action; never re-fetch what you have
- Issues/PRs: search before creating duplicates (gh issue list)
