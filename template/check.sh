#!/bin/bash

clear
echo -e "\n==============================="
echo "Running black (formatting)..."
echo "==============================="
uv run black .
echo -e "\n==============================="
echo "Running ruff (lint and fix)..."
echo "==============================="
ruff check --fix .
#echo -e "\n==============================="
#echo "Running mypy (type checking)..."
#echo "==============================="
#mypy . 
echo -e "\n==============================="
echo "Running pytest (all tests)..."
echo "==============================="
uv run pytest 
echo -e "\n==============================="
echo "All checks and tests complete."
echo "===============================" 