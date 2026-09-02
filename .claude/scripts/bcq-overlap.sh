#!/usr/bin/env bash
# Gate B, deterministic half: list the existing upstream articles a new article overlaps with.
# A neighbour is an article (microsoft/ or community/, excluding the article itself) that shares
# at least MIN shared frontmatter keywords, or whose slug the new article already cites.
# Usage: bcq-overlap.sh <article.md> [min-shared-keywords=2]   -> lines: <shared-count> <path> [<shared keywords>]
set -euo pipefail
source "$(dirname "$0")/_lib.sh"
article="${1:?usage: $0 <article.md> [min]}"; min="${2:-2}"
python3 - "$article" "$min" "$TOOLKIT_ROOT" <<'PY'
import sys, re, glob, os
article, minshared, root = sys.argv[1], int(sys.argv[2]), sys.argv[3]
def keywords(path):
    with open(path, encoding='utf-8') as fh:
        for line in fh:
            m = re.match(r'^keywords:\s*\[(.*)\]', line)
            if m: return {k.strip().strip('"\'').lower() for k in m.group(1).split(',') if k.strip()}
    return set()
text = open(article, encoding='utf-8').read()
mine = keywords(article); slug = os.path.basename(article)[:-3]
out = []
for layer in ('microsoft', 'community'):
    for f in sorted(glob.glob(os.path.join(root, layer, 'knowledge', '*', '*.md'))):
        rel = os.path.relpath(f, root)
        if os.path.basename(f)[:-3] == slug: continue
        shared = sorted(mine & keywords(f))
        cited = os.path.basename(f) in text
        if len(shared) >= minshared or cited:
            out.append((len(shared), rel, shared, cited))
for n, rel, shared, cited in sorted(out, key=lambda t: (-t[0], t[1])):
    print(f"{n} {rel} [{' '.join(shared)}]{' (cited)' if cited else ''}")
PY
