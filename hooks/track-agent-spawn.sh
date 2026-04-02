#!/bin/bash
# Agent Observability Hook (PostToolUse on Task tool)
# Logs agent spawns with timestamp, agent type, model to a tracking file

input=$(cat)

# Pass through the input unchanged (PostToolUse must echo input)
echo "$input"

# Extract agent info and log asynchronously (don't block)
echo "$input" | python3 -c "
import sys, json, os
from datetime import datetime

try:
    data = json.load(sys.stdin)
    tool = data.get('tool', '')
    tool_input = data.get('tool_input', {})

    # Only track Task tool (agent spawns)
    if tool != 'Task':
        sys.exit(0)

    agent_type = tool_input.get('subagent_type', 'unknown')
    model = tool_input.get('model', 'inherited')
    description = tool_input.get('description', '')
    prompt_length = len(tool_input.get('prompt', ''))

    log_dir = os.path.expanduser('~/.claude/logs')
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, 'agent-spawns.jsonl')

    entry = {
        'timestamp': datetime.now().isoformat(),
        'agent_name': agent_type,
        'model': model,
        'description': description,
        'prompt_tokens_est': prompt_length // 4,
        'phase': 'end',
    }

    with open(log_file, 'a') as f:
        f.write(json.dumps(entry) + '\n')

except:
    pass
" 2>/dev/null &
