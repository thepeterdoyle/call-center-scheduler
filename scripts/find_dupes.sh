#!/usr/bin/env bash
set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
  echo "This script uses ripgrep (rg). Install via: brew install ripgrep" >&2
fi

SRC=$(rg -n --glob "sql/**/*.{sql,SQL}" -e '(?i)^\s*(?:--.*)?(CREATE(?:\s+OR\s+REPLACE)?\s+(?:TABLE|VIEW|FUNCTION|PROCEDURE)\s+[`"]?[^`";]+)' || true)

if [[ -z "$SRC" ]]; then
  echo "No create statements found."
  exit 0
fi

echo "$SRC" \
| awk -F: '
  {
    file=$1; line=$2; rest=$0
    sub(/^[^:]+:[0-9]+:/,"",rest)
    sub(/--.*/,"",rest)
    match(rest, /`([A-Za-z0-9_-]+)\.([A-Za-z0-9_-]+)\.([A-Za-z0-9_-]+)`/, m)
    if (m[1]!="") {
      fq=m[1]"."m[2]"."m[3]
    } else {
      match(rest, /(TABLE|VIEW|FUNCTION|PROCEDURE)[[:space:]]+([A-Za-z0-9_-]+)\.([A-Za-z0-9_-]+)/, n)
      if (n[2]!="") fq="?. " n[2] "." n[3]
      else fq="UNKNOWN"
    }
    print fq "\t" file
  }' \
| sort \
| awk -F'\t' '
  { count[$1]++; files[$1]=(files[$1]?files[$1]"\n      - "$2:"      - "$2) }
  END {
    dup=0
    for (o in count) if (count[o]>1) {
      dup=1
      printf "DUPLICATE: %s\n%s\n\n", o, files[o]
    }
    if (!dup) print "✅ No duplicate object definitions found."
  }'

