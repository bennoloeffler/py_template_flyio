#!/bin/bash
./check.sh
fswatch -o \
  -e ".*/\\.venv/.*" \
  -e ".*/\\.git/.*" \
  -e ".*/__pycache__/.*" \
  -e ".*/\\.mypy_cache/.*" \
  -e ".*/\\.pytest_cache/.*" \
  -e ".*/\\.ruff_cache/.*" \
  -e ".*/\\.egg-info/.*" \
  -i "\\.py$" \
  . | while read; do
  ./check.sh
done 