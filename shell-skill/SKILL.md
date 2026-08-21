---
name: shell skill
description: describe how to write shell/bash script code in the codebase, use when you need to add or modify a bash script (e.g. a worker job handler) that shells out to external systems or a REST API
---

# shell script best practices
the document outlines the best practices for writing bash script code in the codebase.

## when to use this skill
when you need to add or modify a bash script, especially one that shells out to external systems (CLI tools, other scripts) or calls a REST API directly via curl

## best practices
+ name shell functions with snake_case, matching the file's existing function names
+ declare every function-local variable with `local`
+ when calling a REST API via `curl`, request JSON and parse it with `jq -r` rather than string-slicing the raw response
+ after parsing a `jq -r` field that may be absent, check for both the empty string and the literal string `"null"` (`[ -z "$var" ] || [ "$var" == "null" ]`) — `jq -r` prints `null` as the string `"null"`, not an empty value, so an empty-only check misses it`"null"` check exists for call sites where the filter doesn't already do this
