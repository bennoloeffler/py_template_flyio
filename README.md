# py_template_flyio

A **Copier template**, an **installer** and a **script for simple usage** for quickly bootstrapping a modern Python web application, ready for ai development with claude code, testing, and deployment on Fly.io.

---

## Quick Start (One Command Setup)

### Prerequisites

You need `curl` installed. Check if you have it:

```bash
curl --version
```

**If curl is not installed:**

- **macOS**: curl is pre-installed
- **Debian/Ubuntu**: `sudo apt-get update && sudo apt-get install -y curl`
- **Fedora/RHEL**: `sudo dnf install -y curl`
- **Alpine**: `apk add curl`

### Check What's Missing

**Check which tools you need (safe - doesn't install):**

```bash
curl -fsSL https://raw.githubusercontent.com/bennoloeffler/py_template_flyio/main/setup-tools.sh | bash
```

### Install Missing Tools

**Install everything:**

```bash
curl -fsSL https://raw.githubusercontent.com/bennoloeffler/py_template_flyio/main/setup-tools.sh | bash -s -- --install
```

This will install:
- Core tools: git, python3.11+, node.js, npm, uv, copier, postgresql, VS Code (with `code` CLI), Claude Code, ripgrep
- Python tools: ruff, black, mypy, pytest, pyenv
- Deployment tools: docker, flyctl, llm
- Shell enhancements: eza, fzf, bat, fd, tree, trash, thefuck
- Shell configuration from `to_zshrc` to the end of ~/.zshrc

**Or download and review before running:**

```bash
curl -O https://raw.githubusercontent.com/bennoloeffler/py_template_flyio/main/setup-tools.sh
chmod +x setup-tools.sh
./setup-tools.sh           # Check what's missing (default - safe)
./setup-tools.sh --install # Install everything
```

---

## Getting Started

After installing the tools, create your first project:

```bash
# Create a projects directory (if you don't have one)
cd ~
mkdir -p projects # create if it does not exist
cd projects

# Generate a new project from the template
# (newpy is a shell function from to_zshrc, installed by setup-tools.sh)

newpy --list # list all versions of the template
# you may use one of the old versions - but probably use the newest...
newpy my-project # this way, your use the NEWEST
newpy my-project --vcs-ref v6 #you may use an older version shown by --list

# Or using copier directly:
copier copy https://github.com/bennoloeffler/py_template_flyio.git my-project --trust

# The template will:
# - Ask you questions (or use defaults based on folder name)
# - Create virtual environment
# - Install dependencies
# - Initialize git repository
# - Run quality checks
# - Open in VS Code
```

After generation completes:

```bash
# vscode is opened in folder
# .venv is activated
# open terminal an run dev server
./run-dev.sh
# Open in browser: 
http://localhost:8877
# run claude in a second terminal
claude

```

---

## Features

- **Fly.io deployment**: Out-of-the-box configuration and Dockerfile for seamless deployment to Fly.io.
- **uv in Docker**: Uses [uv](https://github.com/astral-sh/uv) for fast, reproducible dependency management inside Docker.
- **FastAPI**: Modern, async Python web framework for building APIs and web apps.
- **CLAUDE.md**: how to use tools
- **Code quality tools**: Pre-configured to run `ruff` (linting), `mypy` (type checking), and `black` (formatting).

---

## Manual Usage

This is a **Copier template**. To generate a new project.
Example:

```bash
copier copy https://github.com/bennoloeffler/py_template_flyio.git <app_folder_name>
```

or, if you have a local copy of the template e.g. in your projects folder:



```bash
cd projects
git clone https://github.com/bennoloeffler/py_template_flyio.git
copier copy ./py_template_flyio <app_folder_name>
```

You will be prompted for project-specific values (like `module_name`). If your <app_folder_name> is meaningful, just use all the defaults.

---

## ALL DONE DURING Generation

**so you dont have to e.g. this manually:**
```
  # Try to create databases (may fail if PostgreSQL not running - that's OK)
  - "createdb -U postgres -h localhost -p 5432 {{ module_name }} || echo 'Note: Could not create database {{ module_name }} - ensure PostgreSQL is running'"
  - "createdb -U postgres -h localhost -p 5432 {{ module_name }}_test || echo 'Note: Could not create test database {{ module_name }}_test'"

  # Create virtual environment
  - "uv venv"

  # Initialize git repo
  - "git init"

  # Install ALL dependencies
  - "uv sync --all-extras || echo 'Note: uv sync failed - run manually after fixing any issues'"

  # Run quality checks (may fail on first run - that's expected)
  - "./check.sh || echo 'Note: Some checks failed - this is normal for first run'"
```


**add to github and have a first push before you deploy:  (YOU NEED TO DO THAT)**
```bash
   # do in vscode SHIFT+COMMAND+A -> `Publish To Github`
```


## Development
3. **Run the app:**
   ```bash
   ./run-dev.sh
   ```
4. **Run tests:**
   ```bash
   uv run pytest # for running tests once
   ```
5. **Code quality checks:**
   ```bash
   ruff check .
   mypy .
   black .
   ```
   or, run all checks and tests at once:
   ```bash
   ./checks.sh
   ```
   or, run all checks and tests at once and watch for changes:
   ```bash
   ./check-watch.sh
   ```
6. **Deploy to Fly.io (with Docker):**

## Preparation for production
- login to fly
    ```bash
    fly auth login
    ```
- launch the app
   ```
   fly_launch_to_flyio.sh # creates app and app-test
   ```
- create the postgress cluster for prod and test on flyio
   ```
   fly_create_database_prod.sh # creates app and app-test
   fly_create_database_test.sh # creates app and app-test

   # this will create a secret "DATABASE_URL" in the apps!
   ```

- add the additional secrets needed for production and test apps
    ```bash
    # e.g. ADMIN_PASSWORD=Something12!different
    .env
    # and use
    fly-set-secrets.sh # EDIT TO YOUR NEEDS!
    ```
There are two fly.toml files:
    - fly.prod.toml: for production
    - fly.toml: for testing
    - Whenever you ```fly deploy```, you deploy to the test app, with the default fly.toml file.

But use:
```bash
./fly_deploy_test.sh # for test system 
./fly_deploy_prod.sh # for production system
```
Because then, meaningful git tags are created and pushed to github.

## CLAUDE CODE: Design, Requirements and TODOs
in the docs/ folder, there are three empty files:
 - design.md: for design notes
 - requirements.md: for requirements
 - todos.md: for todos

There is a file ```CLAUDE.md``` file, that you can use to generate the files.

You use these files to document your design, requirements and todos for claude code.
