#!/bin/bash
# Auto-Learning: Update Error Index Hook (Stop)
# Processes error-resolutions.jsonl entries with reusable: null,
# applies reusability heuristics, and updates error-index.md
#
# Follows the passthrough pattern from detect-errors.sh:
# 1. cat stdin, echo it back (passthrough)
# 2. Run update logic in background (async, non-blocking)

input=$(cat)

# Stop hook MUST echo input back (passthrough)
echo "$input"

# Update error index asynchronously (don't block session end)
python3 -c "
import sys, json, os, re
from datetime import datetime
from collections import Counter

try:
    LOG_DIR = os.path.expanduser('~/.claude/logs')
    RESOLUTIONS_FILE = os.path.join(LOG_DIR, 'error-resolutions.jsonl')
    EVENTS_FILE = os.path.join(LOG_DIR, 'error-events.jsonl')
    INDEX_FILE = os.path.join(LOG_DIR, 'error-index.md')

    os.makedirs(LOG_DIR, exist_ok=True)

    # Bail early if no resolutions file
    if not os.path.exists(RESOLUTIONS_FILE):
        sys.exit(0)

    # Read all resolutions
    resolutions = []
    with open(RESOLUTIONS_FILE, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                resolutions.append(json.loads(line))
            except json.JSONDecodeError:
                continue

    # Filter entries with reusable: null (not yet evaluated)
    pending = [r for r in resolutions if r.get('reusable') is None]

    if not pending:
        sys.exit(0)

    # Count error summaries in error-events.jsonl for recurrence detection
    error_summary_counts = Counter()
    if os.path.exists(EVENTS_FILE):
        with open(EVENTS_FILE, 'r') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    evt = json.loads(line)
                    snippet = evt.get('error_snippet', '')
                    # Use first 100 chars of snippet as a rough summary key
                    key = snippet[:100].strip().lower()
                    if key:
                        error_summary_counts[key] += 1
                except json.JSONDecodeError:
                    continue

    # Heuristics for reusability
    REUSABLE_COMMANDS = [
        'pip install', 'pip3 install', 'npm install', 'yarn add',
        'pnpm add', 'apt install', 'apt-get install', 'brew install',
        'chmod', 'chown', 'export ', 'sed ', 'nano ', 'vim ',
        'systemctl', 'mkdir ', 'ln -s',
    ]

    EXPLORATION_COMMANDS = ['cd ', 'ls', 'cat ', 'echo ', 'head ', 'tail ', 'pwd', 'which ']

    def is_reusable(resolution):
        fix_candidates = resolution.get('fix_candidates', [])
        if not isinstance(fix_candidates, list):
            fix_candidates = []

        summary = resolution.get('summary', resolution.get('error_summary', ''))

        # Check if fix_candidates contain reusable patterns
        has_reusable_cmd = False
        for cmd in fix_candidates:
            if not isinstance(cmd, str):
                continue
            cmd_lower = cmd.strip().lower()
            for reusable_pat in REUSABLE_COMMANDS:
                if reusable_pat in cmd_lower:
                    has_reusable_cmd = True
                    break
            if has_reusable_cmd:
                break

        # Check recurrence in error-events.jsonl
        error_snippet = resolution.get('error_snippet', '')
        snippet_key = error_snippet[:100].strip().lower()
        is_recurrent = error_summary_counts.get(snippet_key, 0) >= 2

        if has_reusable_cmd:
            return True

        if is_recurrent:
            return True

        # NOT reusable: only exploration commands
        if fix_candidates:
            all_exploration = all(
                any(cmd.strip().lower().startswith(exp) for exp in EXPLORATION_COMMANDS)
                for cmd in fix_candidates
                if isinstance(cmd, str) and cmd.strip()
            )
            if all_exploration:
                return False

        # NOT reusable: single fix_candidate same as original error command
        orig_cmd = resolution.get('command', resolution.get('original_command', ''))
        if len(fix_candidates) == 1 and isinstance(fix_candidates[0], str):
            if fix_candidates[0].strip() == orig_cmd.strip() and orig_cmd.strip():
                return False

        # Conservative default: not reusable
        return False

    # Evaluate each pending resolution
    new_entries = []  # (category, description, date_str)
    for r in pending:
        reusable = is_reusable(r)
        r['reusable'] = reusable

        if reusable:
            category = r.get('category', 'unknown')
            # Valid categories
            valid_cats = ['config', 'syntax', 'dependency', 'permission',
                          'connection', 'file', 'type', 'memory', 'logic', 'tooling']
            if category not in valid_cats:
                category = 'tooling'  # fallback

            summary = r.get('summary', r.get('error_summary', 'Unknown error'))
            fix_desc = r.get('fix', '')
            if not fix_desc:
                # Build fix from fix_candidates
                candidates = r.get('fix_candidates', [])
                if isinstance(candidates, list) and candidates:
                    fix_desc = '; '.join(
                        c for c in candidates if isinstance(c, str) and c.strip()
                    )[:200]

            error_signal = r.get('matched_pattern', r.get('error_snippet', ''))
            if isinstance(error_signal, str):
                error_signal = error_signal[:100].strip()

            ts = r.get('timestamp', '')
            try:
                date_str = ts[:10] if ts else datetime.now().strftime('%Y-%m-%d')
            except Exception:
                date_str = datetime.now().strftime('%Y-%m-%d')

            # Build short description from summary
            short_desc = summary[:80].strip()
            if not short_desc:
                short_desc = error_signal[:60]

            # Build entry text
            fix_action = fix_desc[:150].strip() if fix_desc else 'ver logs'
            signal = error_signal[:80].strip() if error_signal else short_desc

            new_entries.append((category, short_desc, signal, fix_action, date_str))

    # Rewrite resolutions file with updated reusable flags
    with open(RESOLUTIONS_FILE, 'w') as f:
        for r in resolutions:
            f.write(json.dumps(r) + '\n')

    if not new_entries:
        sys.exit(0)

    # Read current error-index.md
    if not os.path.exists(INDEX_FILE):
        # Create default index
        cats = ['config', 'syntax', 'dependency', 'permission',
                'connection', 'file', 'type', 'memory', 'logic', 'tooling']
        lines = ['# Error Patterns \u2014 Auto-Learned', '',
                 '> Max 10 entries per category. When adding a new entry that exceeds the limit,',
                 '> remove the oldest or least-useful entry in that category.', '']
        for cat in cats:
            lines.extend([f'## {cat}', '', '_No entries yet._', ''])
        index_content = '\n'.join(lines)
    else:
        with open(INDEX_FILE, 'r') as f:
            index_content = f.read()

    # Parse sections
    # Split by ## headers
    section_pattern = re.compile(r'^## (\S+)', re.MULTILINE)
    sections = {}
    matches = list(section_pattern.finditer(index_content))

    for i, m in enumerate(matches):
        cat_name = m.group(1)
        start = m.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(index_content)
        section_body = index_content[start:end].strip()
        sections[cat_name] = section_body

    # Parse existing entries per category
    def parse_entries(body):
        if '_No entries yet._' in body:
            return []
        entries = []
        for line in body.split('\n'):
            line = line.strip()
            if line and re.match(r'^\d+\.', line):
                entries.append(line)
        return entries

    # Add new entries
    for (category, short_desc, signal, fix_action, date_str) in new_entries:
        if category not in sections:
            sections[category] = '_No entries yet._'

        entries = parse_entries(sections[category])

        # Check for duplicate (same short_desc)
        is_dup = any(short_desc.lower() in e.lower() for e in entries)
        if is_dup:
            continue

        new_entry = f'**{short_desc}** \u2014 Quando {signal}, {fix_action}. [{date_str}]'
        entries.append(new_entry)

        # Enforce max 10: remove oldest (first)
        while len(entries) > 10:
            entries.pop(0)

        # Renumber
        numbered = [f'{i+1}. {re.sub(r\"^\d+\\.\\s*\", \"\", e)}' for i, e in enumerate(entries)]
        sections[category] = '\n'.join(numbered)

    # Rebuild the file
    # Preserve header
    header_match = re.search(r'^(.*?)(?=^## )', index_content, re.DOTALL | re.MULTILINE)
    if header_match:
        header = header_match.group(1)
    else:
        header = '# Error Patterns \u2014 Auto-Learned\n\n> Max 10 entries per category. When adding a new entry that exceeds the limit,\n> remove the oldest or least-useful entry in that category.\n\n'

    # Ordered categories
    ordered_cats = ['config', 'syntax', 'dependency', 'permission',
                    'connection', 'file', 'type', 'memory', 'logic', 'tooling']

    output_lines = [header.rstrip()]
    for cat in ordered_cats:
        output_lines.append(f'\n## {cat}\n')
        body = sections.get(cat, '_No entries yet._')
        if not body.strip():
            body = '_No entries yet._'
        output_lines.append(body)

    # Add any extra categories not in ordered list
    for cat in sections:
        if cat not in ordered_cats:
            output_lines.append(f'\n## {cat}\n')
            output_lines.append(sections[cat])

    output_lines.append('')  # trailing newline

    with open(INDEX_FILE, 'w') as f:
        f.write('\n'.join(output_lines))

except Exception:
    pass
" 2>/dev/null &
