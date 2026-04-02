#!/bin/bash
# Block build commands on prod_server only - local dev builds are allowed
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

# Only block on the server (non-macOS = Linux server)
if [[ "$(uname)" == "Darwin" ]]; then
  exit 0
fi

BUILD_PATTERN='(npm run build|npx .* ?build|pnpm (run )?build|yarn (run )?build|bun (run )?build|vite build|next build|nuxt build|remix build|webpack|rollup -|esbuild |tsc --build|tsc -b |cargo build|go build)'

if echo "$COMMAND" | grep -qE "$BUILD_PATTERN"; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOQUEADO: Comandos de build nao devem ser executados no servidor. Use a pipeline de CI/CD."}}'
  exit 0
fi

exit 0
