#!/bin/bash
set -e

timestamp() { date -u +"%Y-%m-%dT%H-%M-%S"; }

# Final message
TAG="Test_$(timestamp)"
MESSAGE="Release to fly.io test system at $(timestamp) by $(whoami)\n\n"

# Create annotated tag
git tag -a "$TAG" -m "$MESSAGE"
git push origin "$TAG"
echo "[deploy_test] Tagged and pushed: $TAG"

# Deploy to Fly
#fly deploy -c fly.prod.toml --no-cache --yes
fly deploy --yes
