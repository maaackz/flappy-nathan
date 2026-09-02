#!/usr/bin/env bash
set -euo pipefail

GODOT="/home/maaackz/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
PROJECT_DIR="/home/maaackz/flappy-nathan"
EXPORT_DIR="$PROJECT_DIR/web-export"
TEMP_DIR=$(mktemp -d)
BRANCH="gh-pages"

echo "=== Exporting web build ==="
mkdir -p "$EXPORT_DIR"
"$GODOT" --path "$PROJECT_DIR" --headless --export-release "Web" "$EXPORT_DIR/index.html"

echo "=== Preparing gh-pages branch ==="
rm -rf "$TEMP_DIR"
git clone --depth 1 --branch "$BRANCH" "$PROJECT_DIR" "$TEMP_DIR" 2>/dev/null || {
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    git init
    git checkout -b "$BRANCH"
}

# Remove old files and copy fresh export
rm -rf "$TEMP_DIR"/*
cp -r "$EXPORT_DIR"/* "$TEMP_DIR"/

cd "$TEMP_DIR"
git add -A
git commit -m "Deploy web export $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
git push origin "$BRANCH" --force

rm -rf "$TEMP_DIR"
echo "=== Deployed to $BRANCH ==="
