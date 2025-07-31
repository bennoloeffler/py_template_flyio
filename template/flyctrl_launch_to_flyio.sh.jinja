#!/bin/bash

echo "=========================================="
echo "DO ALL CHECKS PASS?"
echo "HAVE YOU RUN ./check.sh?"
echo "=========================================="
read -p "Shall I do it now?... (n/Y) " -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running checks..."
    if ./check.sh; then
        echo "=========================================="
        echo "All checks passed. Proceeding with launch..."
        echo "=========================================="
    else
        echo "=========================================="
        echo "FAILED. NO LAUNCH"
        echo "=========================================="
        exit 1
    fi
else
    echo "Skipping checks, proceeding with launch..."
fi

flyctl launch --name '{{project_name}}' --region fra  --yes --now
mv fly.toml fly.prod.toml
flyctl launch --name '{{project_name}}-test' --region fra  --yes --now
