# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues in
[`ViranjPatel/claude-sensei`](https://github.com/ViranjPatel/claude-sensei).

Two toolchains can reach them. **Check which one you have before starting:**

- **`gh` CLI** — the default. Use it whenever `gh` is on PATH (typically local dev).
- **GitHub MCP tools** (`mcp__github__*`) — the fallback. Claude Code on the web and other
  remote sessions ship these *instead of* `gh`; there, `gh` is absent and every `gh` command
  below will fail with `command not found`.

Detect with `which gh`. Don't install `gh` in a remote session — use the MCP tools.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` — `gh` does this automatically when run inside a clone.

## MCP equivalents

When `gh` is unavailable, use these tools instead. They are *deferred*: load a schema with
`ToolSearch` (`select:mcp__github__issue_write,mcp__github__issue_read`) before calling, then
pass `owner: "ViranjPatel"`, `repo: "claude-sensei"` explicitly — there is no
infer-from-remote behaviour.

| Operation | `gh` | MCP tool |
| --- | --- | --- |
| Create an issue | `gh issue create` | `mcp__github__issue_write` (create method) |
| Read an issue + comments | `gh issue view --comments` | `mcp__github__issue_read` |
| List / filter issues | `gh issue list` | `mcp__github__list_issues` |
| Search issues | `gh issue list --search` | `mcp__github__search_issues` |
| Comment | `gh issue comment` | `mcp__github__add_issue_comment` |
| Apply / remove labels | `gh issue edit --add-label` | `mcp__github__issue_write` (update method, `labels`) |
| Close | `gh issue close` | `mcp__github__issue_write` (update, `state` + `state_reason`) |
| Read a PR | `gh pr view` | `mcp__github__pull_request_read` |
| List PRs | `gh pr list` | `mcp__github__list_pull_requests` |
| Sub-issue link | `gh api .../sub_issues` | `mcp__github__sub_issue_write` |

Two MCP-only caveats:

- **`gh api` has no general MCP equivalent.** Raw REST calls in the wayfinding section below
  (issue dependencies, database ids) have no typed tool. Fall back to the body-text
  conventions those bullets already describe.
- **Repo scope is enforced.** Remote sessions are scoped to an allowlist of repos; calls
  against anything outside it are denied rather than 404'd.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either — resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments` (or `mcp__github__issue_read`).

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint, or `mcp__github__sub_issue_write`). Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies** — the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only — the live gate). Without `gh api` (MCP-only sessions) or where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue list --state open`, scoped to the map's sub-issues / task list), drop any with an open blocker (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me` — the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
