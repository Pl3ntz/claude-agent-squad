#!/bin/bash
# Request-Completion Stop Hook
# Blocks Claude from stopping unless:
# 1. stop_hook_active is true (prevent infinite loops)
# 2. Response is short (simple question/answer — under 500 chars)
# 3. Response contains a ### RESUMO section

# Capture stdin first, then pass to python3
input=$(cat)

echo "$input" | python3 -c "
import sys, json, re

try:
    data = json.load(sys.stdin)
except:
    sys.exit(0)

stop_active = data.get('stop_hook_active', False)
last_message = data.get('last_assistant_message', '')

# CRITICAL: Prevent infinite loops
if stop_active:
    sys.exit(0)

# Short responses are simple Q&A
if len(last_message) < 500:
    sys.exit(0)

# Check for completion summary (### RESUMO)
if re.search(r'### RESUMO', last_message, re.IGNORECASE):
    sys.exit(0)

# Block: RESUMO missing
print(json.dumps({
    'decision': 'block',
    'reason': 'Antes de parar, inclua um ### RESUMO no final da sua resposta explicando: qual o impacto, como foi feito, e o que foi entregue.'
}))
sys.exit(0)
"
