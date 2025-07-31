#!/bin/bash

flyctl launch --name '{{project_name}}' --region fra  --yes --now
mv fly.toml fly.prod.toml
flyctl launch --name '{{project_name}}-test' --region fra  --yes --now
