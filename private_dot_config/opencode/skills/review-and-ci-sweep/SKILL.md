---
name: review-and-ci-sweep
description: Keep PR checks green and resolve new review comments by iterating until no new feedback remains.
---

Scope

- Target: GitHub PRs only
- Goal: All checks green, no unresolved review threads
- Loop cadence: Recheck every 2 minutes

Triggers

- “keep CI green”
- “iterate on PR until green”
- “fix all comments/discussions and recheck”

Inputs

- PR number or URL

Steps

1. Fetch PR status checks and review decision.
2. Fetch review threads and PR discussions; filter unresolved or new.
3. If checks still running, wait 2 minutes and repeat step 1.
4. If unresolved threads exist:
   - Identify required code changes.
   - Implement minimal fixes.
   - Run diagnostics on changed files.
   - Commit and push.
   - Resolve threads in GitHub.
   - Return to step 1.
5. If a thread or discussion is invalid or no code change is needed:
   - Reply with rationale.
   - Resolve the thread in GitHub.
   - Return to step 1.
6. If new PR discussion comments appear (non-threaded):
   - Respond with rationale or action plan.
   - If changes are needed, follow step 4.
   - Return to step 1.
7. Stop when: all checks green AND no unresolved threads or new discussions.
8. Report final PR status and approvals state.

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

```
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
}' -f owner=ORG -f repo=REPO -F number=123 \
| jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)'

# Resolve a review thread (GraphQL)
gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{isResolved} } }' \
  -F id=THREAD_ID

# PR discussion comments (issue comments)
gh api repos/ORG/REPO/issues/123/comments

# Reply to a PR review comment
gh api repos/ORG/REPO/pulls/comments/COMMENT_ID/replies -f body="<rationale>"
```
