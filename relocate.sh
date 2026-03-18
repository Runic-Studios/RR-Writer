#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$SCRIPT_DIR/content"
RELOCATED_DIR="$SCRIPT_DIR/relocated"
RELOCATIONS_FILE="$SCRIPT_DIR/relocations.yml"

rm -rf "$RELOCATED_DIR"
mkdir -p "$RELOCATED_DIR"

count=$(yq e '.relocations | length' "$RELOCATIONS_FILE")

for i in $(seq 0 $((count - 1))); do
  type=$(yq e ".relocations[$i].type" "$RELOCATIONS_FILE")
  source=$(yq e ".relocations[$i].source" "$RELOCATIONS_FILE")
  target=$(yq e ".relocations[$i].target" "$RELOCATIONS_FILE")

  src_path="$CONTENT_DIR/$source"
  dest_path="$RELOCATED_DIR/$target"

  if [ ! -e "$src_path" ]; then
    echo "WARNING: source '$source' not found in content/, skipping"
    continue
  fi

  case "$type" in
    directory)
      mkdir -p "$dest_path"
      cp -r "$src_path/." "$dest_path/"
      ;;
    file)
      mkdir -p "$(dirname "$dest_path")"
      cp "$src_path" "$dest_path"
      ;;
    zip)
      mkdir -p "$dest_path"
      unzip -q "$src_path" -d "$dest_path/"
      ;;
    *)
      echo "WARNING: unknown relocation type '$type' for source '$source', skipping"
      ;;
  esac
done
