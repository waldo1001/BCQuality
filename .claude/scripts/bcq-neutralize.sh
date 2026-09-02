#!/usr/bin/env bash
# Prepare a sample for a cold review: copy it under an opaque name, strip full-line comments,
# and neutralise the Good/Bad tokens in object names, so nothing in the input reveals the expected verdict.
# Usage: bcq-neutralize.sh <sample.al> [out-dir]   -> prints the neutral file path
set -euo pipefail
src="${1:?usage: $0 <sample.al> [out-dir]}"
out="${2:-${TMPDIR:-/tmp}/bcq-cold}"
mkdir -p "$out"
hash=$(shasum "$src" | cut -c1-8)
dst="$out/case-$hash.al"
grep -vE '^\s*//' "$src" \
  | perl -pe 's/ ?(Good|Bad)"/"/g; s/\b(I[A-Za-z]+?)(Good|Bad)\b/$1/g; s/\b([A-Za-z]+?)(Good|Bad)\b/$1/g' \
  > "$dst"
echo "$dst"
