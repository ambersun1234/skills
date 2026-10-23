#!/usr/bin/env bash
# UserPromptSubmit hook: a short per-turn reminder, so it sits next to the
# latest message instead of deep inside CLAUDE.md.

cat <<'EOF'
Reminder (local skills):
- Before writing or reviewing code, load the matching local skills (code-review-skill, unit-test-skill, integration-test-skill, middleware-skill, database-skill, logging-skill, cache-skill, message-queue-skill, shell-skill, doc-skill) with the Skill tool. Don't rely on memory of their contents.
- Unsure about an architecture or design choice: load the blog MCP with ToolSearch "select:mcp__blog-mcp__search_blog_rag" and search it before deciding.
- Any screen use (recording, Claude in Chrome): load screen-recording-skill and take its lock first. Posting a test report: load test-report-skill. Design canvas work: load claude-design. GitHub posting/PR/merge: load github-workflow.
EOF
