# py_template_flyio

A **Copier template** for quickly bootstrapping a modern Python web application, ready for best-practice development, testing, and deployment on Fly.io.

---

## Features

- **Fly.io deployment**: Out-of-the-box configuration and Dockerfile for seamless deployment to Fly.io.
- **uv in Docker**: Uses [uv](https://github.com/astral-sh/uv) for fast, reproducible dependency management inside Docker.
- **FastAPI**: Modern, async Python web framework for building APIs and web apps.
- **Cursor rules prepared**: Includes some new type of cursor rules for best-practice development with Cursor.
- **Code quality tools**: Pre-configured to run `ruff` (linting), `mypy` (type checking), and `black` (formatting).

---

## Usage

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
  - ```uv sync```
  - ```uv sync --dev```
  - ```git init```
  - ```git add .```
  - ```uv pip install pre-commit```
  - ```pre-commit install```
  - ```flyctl launch --name '{{project_name}}' --region fra --now```
  - ```mv fly.toml fly.prod.toml```
  - ```flyctl launch --name '{{project_name}}-test' --region fra --now```


1. **Create and activate a virtual environment:**
   ```bash
   uv venv
   source .venv/bin/activate
   uv sync
   uv sync --dev

   ```
2. **Init git repo and hook up pre-commit:**
   ```bash
   git init
   git add .
   uv pip install pre-commit
   pre-commit install
   ```

3. **Deploy to Fly.io (with Docker):**
   ```bash
   flyctl launch --name '{{project_name}}' --region fra --now
   mv fly.toml fly.prod.toml
   flyctl launch --name '{{project_name}}-test' --region fra --now
   ```

4. **Create secrets:**
   ```bash
   flyctl secrets set OPENAI_API_KEY=$OPENAI_API_KEY
   flyctl secrets set DB_FOLDER="/data"
   ```

4. **Create a volume for the database:**
   ```bash
   flyctl volumes create bels_volume --region fra --size 1
   ```

## Development
3. **Run the app:**
   ```bash
   uvicorn <your_module>.main:app --reload
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
There are two fly.toml files:
    - fly.prodt.toml: for production
    - fly.toml: for testing
    - Whenever you ```fly deploy```, you deploy to the test app, with the default fly.toml file.

    But use:
    ```bash
    ./deploy_test_fly.sh # for test system 
    ./deploy_prod_fly.sh # for production system
    ```
    Because then, meaningful git tags are created and pushed to github.
   
## Preparation for production
- login to fly
    ```bash
    fly auth login
    ```
- add the secrets needed for production and test apps
    ```bash
    fly secrets set <key>="<value>"
    ```
There are two secrets already set:
- OPENAI_API_KEY (from your env variable)
- DB_FOLDER (to ```/data```)

You can add more secrets to the production and test apps.

## Design, Requirements and TODOs: Basis for Cursor
in the docs/ folder, there are three empty files:
 - design.md: for design notes
 - requirements.md: for requirements
 - todos.md: for todos

There is a file ```PROMPT_for_O3.md``` file, that you can use to generate the files.

You use these files to document your design, requirements and todos for cursor.

## Cursor Rules
see folder .cursor/rules/rule_xxx.mdc
Old style: cursorrules.yaml/json not used anymore.

# TODOs
- create a better README.md for the template
- add a check for uncommitted files before deployment. Stop if not committed.
- changelog with llm from prod release to prod release does not work yet
