---
name: review-and-ci-sweep
description: Keep PR checks green and resolve new review comments by iterating until no new feedback remains.
---

Scope

- Target: GitHub PRs only
- Goal: All checks green, no unresolved review threads
- Loop cadence: Recheck every 15 seconds
- Max iterations: 120 (~30 minutes). Stop and report status if exceeded.

Triggers

- "keep CI green"
- "iterate on PR until green"
- "fix all comments/discussions and recheck"

Inputs

- PR number or URL

Setup

1. Derive owner and repo from the PR context:
   ```bash
   gh repo view --json owner,name -q '.owner.login + " " + .name'
   ```
2. Initialize tracking state: `LAST_SEEN_COMMENT_ID=0`, `ITERATION=0`.

Steps

1. Increment iteration counter. If `ITERATION > 120`, stop and report current status.
2. Fetch PR status checks and review decision.
3. Fetch review threads (via GraphQL) and PR discussion comments (via REST); filter unresolved or new (comment ID > `LAST_SEEN_COMMENT_ID`). Update `LAST_SEEN_COMMENT_ID` to the highest seen ID.
4. If checks still running, wait 15 seconds (`sleep 15`) and repeat from step 1.
5. If checks failed and the failure is re-runnable (flaky test, transient infra), attempt `gh run rerun --failed` once per failed run. Return to step 1.
6. If unresolved threads exist:
   - Identify required code changes.
   - Implement minimal fixes.
   - Run the repo's local CI gate on changed files (lint, typecheck, tests — use `trunk check`, `make test`, or whatever the repo defines).
   - Commit and push.
   - Resolve threads in GitHub.
   - Return to step 1.
7. If a thread or discussion is invalid or no code change is needed:
   - Reply with rationale.
   - Resolve the thread in GitHub.
   - Return to step 1.
8. If new PR discussion comments appear (ID > `LAST_SEEN_COMMENT_ID`, non-threaded):
   - Respond with rationale or action plan.
   - If changes are needed, follow step 6.
   - Return to step 1.
9. Stop when: all checks green AND no unresolved threads AND no new discussions.
10. Report final PR status, approvals state, and iteration count.

Constraints

- No unrelated refactors.
- No destructive git operations.
- No commit amend unless explicitly requested.
- Do not skip hooks unless explicitly requested.
- Use existing repo conventions for commits and imports.

Safety

- Never force push.
- Never push to main/master unless explicitly asked.
- Do not merge PR unless explicitly asked.
- If checks are failing for unrelated reasons, report without altering.

Examples

```
PR: https://github.com/org/repo/pull/123
```

Commands

```bash
# Derive owner and repo
eval $(gh repo view --json owner,name -q '"OWNER=\(.owner.login) REPO=\(.name)"')

# Status checks + review decision
gh pr view <PR> --json statusCheckRollup,reviewDecision

# Unresolved review threads (GraphQL)
gh api graphql -f query='
query($owner:String!,$repo:String!,$number:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{ id isResolved path line comments(first:1){ nodes{ id body author{login} } } }
      }
    }
  }
}' -f owner="$OWNER" -f repo="$REPO" -F number=<PR_NUMBER> \
| jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)'

# Resolve a review thread (GraphQL)
gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{isResolved} } }' \
  -F id=THREAD_ID

# PR discussion comments (issue comments), sorted for tracking
gh api "repos/$OWNER/$REPO/issues/<PR_NUMBER>/comments" --jq '.[] | {id, body, user: .user.login, updated_at}'

# PR review comments (inline on diffs)
gh api "repos/$OWNER/$REPO/pulls/<PR_NUMBER>/comments" --jq '.[] | {id, body, path, line, user: .user.login}'

# Reply to a PR review comment
gh api "repos/$OWNER/$REPO/pulls/comments/COMMENT_ID/replies" -f body="<rationale>"

# Re-run failed CI checks
gh run rerun <RUN_ID> --failed
```
