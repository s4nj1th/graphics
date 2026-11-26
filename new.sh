#!/bin/sh

set -euo pipefail

cd "$(dirname "$0")"

TEMPLATE="_template"

if [ $# -lt 1 ]; then
  echo "Usage: ./new.sh <topic name>"
  exit 1
fi

if [ ! -d "$TEMPLATE" ]; then
  echo "Error: $TEMPLATE/ not found in $(pwd)"
  exit 1
fi

topic="$*"

slug=$(echo "$topic" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')

if [ -z "$slug" ]; then
  echo "Error: topic name has no usable characters"
  exit 1
fi

last=0
for d in [0-9][0-9]_*/; do
  [ -d "$d" ] || continue
  n=$((10#${d%%_*}))
  if [ "$n" -gt "$last" ]; then
    last=$n
  fi
done

next=$(printf "%02d" $((last + 1)))
target="${next}_${slug}"

if [ -e "$target" ]; then
  echo "Error: $target already exists"
  exit 1
fi

cp -r "$TEMPLATE" "$target"
mkdir -p "$target/out"

if [ -f README.md ]; then
  echo "| [$target]($target/) | $topic |" >> README.md
fi

echo "Created $target/"
echo "  open:   $target/main.ipynb"
echo "  commit: git add $target README.md && git commit -m \"$next: $topic\" && git push"
