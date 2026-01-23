// plugin/compaction-preserver.ts
var PRESERVATION_CONTEXT = `
CRITICAL CONTEXT TO PRESERVE:
- Current working directory
- Any file paths mentioned in the last 5 messages
- Any error messages or stack traces
- The user's original request/goal
- Any architectural decisions made
- Test results and their status

DO NOT LOSE:
- Active todo items and their status
- Files that were modified but not yet committed
- Any blocking issues or open questions
`;
var plugin = async ({ worktree }) => {
  return {
    "experimental.session.compacting": async (_input, output) => {
      output.context.push(`Working directory: ${worktree}
${PRESERVATION_CONTEXT}`);
    }
  };
};
var compaction_preserver_default = plugin;
export {
  compaction_preserver_default as default
};
