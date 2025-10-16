# py_template_flyio

A **Copier template** for quickly bootstrapping a modern Python web application, ready for best-practice development, testing, and deployment on Fly.io.

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
- Development tools: ruff, black, mypy, pytest
- Deployment tools: docker, flyctl, llm
- Shell enhancements: eza, fzf, bat, fd, tree, trash, thefuck, pyenv
- Shell configuration from `to_zshrc`

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
mkdir -p projects
cd projects

# Generate a new project from the template
# (newpy is a shell function from to_zshrc, installed by setup-tools.sh)
newpy my-new-project

# Or using copier directly:
copier copy https://github.com/bennoloeffler/py_template_flyio.git my-new-project --trust

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
cd my-new-project
source .venv/bin/activate  # Activate virtual environment

# Run the development server
uv run uvicorn my_new_project.main:app --reload --port 8877

# Open in browser: http://localhost:8877
```

---

## Features

- **Fly.io deployment**: Out-of-the-box configuration and Dockerfile for seamless deployment to Fly.io.
- **uv in Docker**: Uses [uv](https://github.com/astral-sh/uv) for fast, reproducible dependency management inside Docker.
- **FastAPI**: Modern, async Python web framework for building APIs and web apps.
- **Cursor rules prepared**: Includes some new type of cursor rules for best-practice development with Cursor.
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
  - ```uv venv```
  - ```git init```
  - ```flyctl launch --name '{{project_name}}' --region fra --now```
  - ```mv fly.toml fly.prod.toml```
  - ```flyctl launch --name '{{project_name}}-test' --region fra --now```
  - ```uv sync --dev```
  - ```git add .```


1. **Create and activate a virtual environment:**
   ```bash
   uv venv
   source .venv/bin/activate
   uv sync
   uv sync --dev

   ```
2. **Init git repo:**
   ```bash
   git init
   git add .
   ```

3. **Deploy to Fly.io (with Docker):**
   ```bash
   flyctl launch --name '{{project_name}}' --region fra --now
   mv fly.toml fly.prod.toml
   flyctl launch --name '{{project_name}}-test' --region fra --now
   ```

4. **Create secrets (YOU NEED TO DO THAT)**
   ```bash
   flyctl secrets set OPENAI_API_KEY=$OPENAI_API_KEY
   flyctl secrets set DB_FOLDER="/data"
   ```

4. **Create a volume for the database:  (YOU NEED TO DO THAT)**
   ```bash
   flyctl volumes create bels_volume --region fra --size 1
   ```
4. **add to github and have a first push before you deploy:  (YOU NEED TO DO THAT)**
   ```bash
   # do in vscode SHIFT+COMMAND+A -> `Publish To Github`
   ```


## Development
3. **Run the app:**
   ```bash
   uvicorn <your_module>.main:app 
   uv run uvicorn <your_module>.main:app --reload --port 9876 #dev mode
   ```
4. **Run tests:**
   ```bash
   pytest # for running tests once
   # or
   ptw # for watching only tests
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
   ./rcheck-watch.sh
   ```
6. **Deploy to Fly.io (with Docker):**

## Preparation for production
- login to fly
    ```bash
    fly auth login
    ```
- add the secrets needed for production and test apps
    ```bash
    fly secrets set <key>="<value>"
    ```
There are two fly.toml files:
    - fly.prod.toml: for production
    - fly.toml: for testing
    - Whenever you ```fly deploy```, you deploy to the test app, with the default fly.toml file.

But use:
```bash
./deploy_test_fly.sh # for test system 
./deploy_prod_fly.sh # for production system
```
Because then, meaningful git tags are created and pushed to github.

## Design, Requirements and TODOs: Basis for Cursor
in the docs/ folder, there are three empty files:
 - design.md: for design notes
 - requirements.md: for requirements
 - todos.md: for todos

There is a file ```CLAUDE.md``` file, that you can use to generate the files.

You use these files to document your design, requirements and todos for cursor.

## Cursor Rules
see folder .cursor/rules/rule_xxx.mdc
Old style: cursorrules.yaml/json not used anymore.
