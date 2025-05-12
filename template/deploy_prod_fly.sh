#!/bin/bash
set -e

timestamp() { date -u +"%Y-%m-%dT%H-%M-%S"; }

#echo "[deploy_prod] Compiling requirements.txt..."
#uv pip compile pyproject.toml -o requirements.txt

# Get last production tag
LAST_TAG=$(git tag --list 'Production_*' --sort=-creatordate | head -n 1)

if [ -z "$LAST_TAG" ]; then
  COMMITS=""
else
  COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"- %s")
fi

NO_INFO="No Info found."

if [ -z "$COMMITS" ]; then
  SUMMARY="$NO_INFO"
else
  SUMMARY=$(echo "$COMMITS" | llm "Summarize these commit messages for a changelog. If there are no logs, just say '$NO_INFO':")
fi

# Final message
TAG="Production_$(timestamp)"
MESSAGE="Release to fly.io production system at $(timestamp) by $(whoami)\n\n$SUMMARY"

# Append to changelog
echo -e "\n## $TAG\n$MESSAGE" >> CHANGELOG.md
echo "[deploy_prod] Appended to CHANGELOG.md"

# Create annotated tag
git tag -a "$TAG" -m "$MESSAGE"
git push origin "$TAG"
echo "[deploy_prod] Tagged and pushed: $TAG"

# Deploy to Fly
#fly deploy -c fly.prod.toml --no-cache --yes
fly deploy -c fly.prod.toml --yes
