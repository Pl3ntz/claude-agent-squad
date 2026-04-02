#!/bin/bash
# Test Gate — PreToolUse Hook on Bash
# Blocks git commit if no test execution detected in the session transcript
#
# Strategy: When command is "git commit", check transcript for test execution
# If no tests found, BLOCK with message to run tests first
#
# I/O Contract (PreToolUse):
# - Input: JSON via stdin (tool_name, tool_input)
# - Output: JSON with permissionDecision deny to block, {} to allow
# - Exit 0 always

input=$(cat)

# Fast path: extract command
command=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$command" ]; then
  echo '{}'
  exit 0
fi

# Only gate git commit commands
if ! echo "$command" | grep -qE '^\s*git\s+commit\b|^\s*git\s+add\s.*&&\s*git\s+commit'; then
  echo '{}'
  exit 0
fi

# Check session transcript for test execution
transcript_path=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path',''))" 2>/dev/null)

if [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  # No transcript available — allow (don't block without evidence)
  echo '{}'
  exit 0
fi

# Search transcript for test execution patterns
if grep -qiE 'npm\s+test|npx\s+vitest|npx\s+jest|pytest|python3?\s+-m\s+pytest|cargo\s+test|go\s+test|mix\s+test|bundle\s+exec\s+rspec|vitest\s+run' "$transcript_path" 2>/dev/null; then
  # Tests were run in this session
  echo '{}'
  exit 0
fi

# No test execution found — BLOCK
echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"TEST GATE: Nenhuma execucao de testes detectada nesta sessao. Rode os testes antes de commitar. Use: npm test, pytest, vitest run, etc."}'
exit 0
