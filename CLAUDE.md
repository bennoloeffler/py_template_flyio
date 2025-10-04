# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **Copier template repository** for generating Python FastAPI applications ready for Fly.io deployment. This is NOT a regular Python project - it's a template that generates other projects.

### Key Distinction
- **This repository** (`py_template_flyio`): The template source code
- **Generated projects**: Created by running `copier copy` command
- Files ending in `.jinja` are templates that get processed during generation
- `template/CLAUDE.md.jinja` becomes the `CLAUDE.md` for generated projects

## Template Architecture
when in doubt: read the docs:
- with mcp context7: copier 
- or https://copier.readthedocs.io/en/stable/


### Copier Concepts Used
- **`copier.yml`**: Defines questions asked during generation and template configuration
- **`.jinja` suffix**: Files processed with Jinja2 templating (variables replaced)
- **`_subdirectory: template`**: All template files are in `template/` directory
- **`_tasks`**: Shell commands executed after generation (in `copier.yml:67-92`)
- **Template variables**: `{{ module_name }}`, `{{ project_name }}`, etc.

### Directory Structure
```
py_template_flyio/
├── copier.yml                    # Template configuration and questions
├── README.md                     # Documentation for template users
├── CLAUDE.md                     # THIS FILE - for maintaining template
└── template/                     # All files that get copied to generated projects
    ├── {{module_name}}/          # Python package (name from user input)
    │   ├── main.py.jinja         # FastAPI application with authentication
    │   ├── config.py.jinja       # Settings management
    │   ├── db.py.jinja           # PostgreSQL database layer
    │   ├── db_migrate.py.jinja   # Migration utility
    │   ├── models.py.jinja       # Pydantic models and SQLAlchemy ORM
    │   ├── upload_files.py.jinja # File upload and thumbnail generation
    │   ├── html_templates/       # Jinja2 HTML templates
    │   │   ├── base.html         # Base template with mobile-responsive nav
    │   │   ├── index.html        # Home page with hero section
    │   │   ├── login.html        # User login form
    │   │   ├── register.html     # User registration form
    │   │   ├── files.html        # File listing and search
    │   │   ├── upload.html       # File upload interface
    │   │   ├── admin.html        # Admin dashboard
    │   │   ├── counter.html      # Example counter page
    │   │   ├── 404.html          # Not found error page
    │   │   └── 500.html          # Server error page
    │   └── static/               # Static assets
    │       ├── style.css         # Responsive CSS with mobile design
    │       ├── home-icon.svg     # Navigation icon
    │       └── icon.png          # Favicon
    ├── tests/                    # Test files
    ├── docs/                     # Documentation templates
    │   ├── design.md.jinja       # Design specifications
    │   ├── requirements.md.jinja # Requirements documentation
    │   ├── todos.md.jinja        # Project todos
    │   └── features_concepts/    # Feature documentation
    ├── .cursor/rules/            # Cursor AI rules
    ├── CLAUDE.md.jinja           # Guidance for generated projects
    ├── check.sh                  # Quality checks script
    └── Dockerfile.jinja          # Docker configuration
```

### Variable Naming Conventions
- **`project_name`**: Kebab-case, used for Fly.io app names, git repos (e.g., `my-app`)
- **`module_name`**: Snake_case, used for Python package names (e.g., `my_app`)
- **Default behavior**: Derived from destination folder name if not specified

## Key Features Included

### Authentication & Authorization
- **JWT-based authentication** with secure token handling
- **Role-based access control** (visitor, user, admin)
- **Optional authentication** for public endpoints
- **Admin auto-creation** on first startup

### File Management
- **File upload** with unique filename generation
- **Image thumbnail generation** using Pillow
- **File search and filtering** by title and user
- **Public file access** for visitors
- **Role-based file operations** (upload, delete)

### User Interface
- **Mobile-responsive design** with Tailwind CSS
- **Progressive enhancement** for authentication state
- **Modern navigation** with mobile hamburger menu
- **Hero section** with call-to-action buttons
- **Clean, professional styling**

### Database & Backend
- **PostgreSQL integration** with SQLAlchemy ORM
- **Database migrations** with db_migrate utility
- **Environment-based configuration**
- **Rate limiting** for API protection
- **Error handling** with custom error pages

### Deployment Ready
- **Docker containerization**
- **Fly.io deployment scripts**
- **Production configuration**
- **Quality assurance scripts** (black, ruff, mypy, pytest)

## Development Commands

### Testing Template Generation Locally
```bash
# Generate a test project from local template
cd /Users/benno/projects/ai/
copier copy ./py_template_flyio test_generated_app

# Answer prompts or use defaults
# Inspect generated project
cd test_generated_app
ls -la

# Clean up test
cd ..
rm -rf test_generated_app
```

### Testing Generated Project
```bash
# After generating a project, test it works:
cd test_generated_app
source .venv/bin/activate  # Created by _tasks
uv sync --extra dev
./check.sh                  # Runs black, ruff, mypy, pytest
uv run uvicorn <module>.main:app --reload --port 8877
```

### Modifying Template Files
```bash
# Edit template files directly
code template/{{module_name}}/main.py.jinja

# Test changes by regenerating a project
copier copy ./py_template_flyio test_generated_app --force
```

### Quality Checks for Template
```bash
# Check for syntax errors in .jinja files
# (Copier validates on generation)
copier copy . /tmp/test_gen --defaults

# Validate copier.yml syntax
copier --help-all
```

## Critical Template Weaknesses

### 1. Task Execution Reliability (`copier.yml:67-92`)
**Problem**: Many critical post-generation tasks are commented out or may fail silently.

**Issues**:
- Database creation assumes PostgreSQL running locally with no password
- Flyctl commands commented out - forces manual deployment setup
- `uv sync` order is inconsistent
- No error handling if tasks fail

**Impact**: Users must manually complete setup, easy to miss steps.

**Fix Needed**:
- Add clear documentation about prerequisites
- Make tasks idempotent and add error messages
- Consider making fly.io setup optional

### 2. Database Migration Strategy
**Problem**: `db_migrate.py.jinja` exists but has no clear integration story.

**Issues**:
- No guidance on when/how to use migrations in generated projects
- `DROP_TABLES_BEFORE_INIT=true` is dangerous but used casually
- Test database setup in tasks but no teardown

**Impact**: Users may lose data or have inconsistent schemas.

**Fix Needed**:
- Document migration workflow clearly
- Remove dangerous DROP_TABLES from casual use
- Add proper test database lifecycle management

### 3. Configuration Security
**Problem**: Default secrets are insecure and may reach production.

**Issues**:
- `config.py.jinja` has `secret_key: "change-me-in-production"`
- `admin_password: "admin123"` is weak default
- No validation that secrets were changed before deployment
- `.env.example.jinja` relationship to actual `.env` unclear

**Impact**: Production deployments with default credentials.

**Fix Needed**:
- Generate random secrets during template generation
- Add startup validation to refuse insecure defaults
- Clarify .env setup in documentation

### 4. Jinja Variable Inconsistencies
**Problem**: Variable usage patterns are inconsistent across template.

**Issues**:
- Mix of `{{ module_name }}` and `{{ project_name }}` not always semantic (module_name can be used as python identifier, camel_case, project_name may not kebab-case)
- Default generation (`copier.yml:19,24`) may produce invalid Python identifiers
- No sanitization of user input for special characters

**Impact**: Generated projects may have invalid package names.

**Fix Needed**:
- Add validation/sanitization in copier.yml
- Document when to use which variable
- Add tests for edge cases (spaces, special chars)


### 6. Documentation Fragmentation
**Problem**: Multiple documentation files with unclear relationships.

**Issues**:
- `CLAUDE.md.jinja` references features (file uploads, users) not in base template
- `CLAUDE_BBS.md` not templated - same content in all projects
- `docs/features_concepts/` has many examples not in base template
- Design/requirements/todos templates are empty shells

**Impact**: Generated projects have misleading documentation.

**Fix Needed**:
- Make CLAUDE.md.jinja match actual base template features
- Template or remove CLAUDE_BBS.md
- Remove example feature docs or mark as examples
- Provide better starter content for design/requirements

### 7. Testing Coverage Gaps
**Problem**: Generated projects have minimal test coverage.

**Issues**:
- Only `test_main.py.jinja` exists
- No tests for db.py, config.py modules
- No test fixtures for database
- No integration tests for API endpoints

**Impact**: Generated projects start with poor test discipline.

**Fix Needed**:
- Add test templates for all modules
- Provide test fixtures (database, auth)
- Add example integration tests
- Document testing strategy in CLAUDE.md.jinja

### 8. Cursor Rules Not Properly Templated
**Problem**: Cursor rules mix static and templated files inconsistently.
REMOVE CURSOR DESCRIPTION!!!

**Issues**:
- Some `.mdc` files, some `.mdc.jinja` files
- Variable references in non-.jinja files won't work
- `check-all-tools.mdc.jinja` references `{{ module_name }}` but may not process

**Impact**: Cursor rules may not work in generated projects.


### 9. Git Workflow Issues
**Problem**: Git initialization happens too early in tasks.

**Issues**:
- `git add .` runs in tasks before user reviews files
- User can't inspect generated files before committing
- Template's own `.git` in subdirectory may cause confusion
- No .gitignore includes during generation

**Impact**: Users commit without review, potential sensitive data leaks.

**Fix Needed**:
- Remove `git add .` from tasks
- Add clear "next steps" section to README
- Ensure .gitignore.jinja is comprehensive

### 10. Dependency Management Complexity
**Problem**: Default dependencies are very opinionous and potentially unused.

**Issues**:
- `dependencies` in copier.yml includes openai, redis, slowapi by default
- New projects carry unused dependencies
- `mypy` added in task but should be in dev dependencies from start
- No guidance on removing unused packages

**Impact**: Bloated projects, confusion about what's needed.

**Fix Needed**:
- Reduce default dependencies to essentials only
- Make some dependencies optional (prompts in copier.yml)
- Document dependency removal process
- Fix mypy to be in pyproject.toml dev dependencies

## Template Maintenance Guidelines

### When to Use `.jinja` Suffix
**Use `.jinja`** when file contains:
- Copier template variables: `{{ module_name }}`, `{{ project_name }}`, etc.
- Conditional blocks: `{% if ... %}`, `{% for ... %}`
- File/folder name uses variables: `{{module_name}}/`

**Don't use `.jinja`** when:
- File is identical for all generated projects
- No variable substitution needed
- Example: `check.sh`, `pytest.ini`

### Testing `_tasks` Execution
```bash
# Tasks run in generated project directory, not template directory
# To test, must actually generate a project

# Prerequisites for tasks to succeed:
# - PostgreSQL running on localhost:5432
# - User 'postgres' with no password or password in PGPASSWORD
# - uv installed
# - git installed

# Test full generation:
copier copy ./py_template_flyio /tmp/test_proj
cd /tmp/test_proj
# Check what worked:
ls -la .venv/  # Should exist
git status     # Should be initialized
```

### Handling Default Values and Secrets
**Current approach** (weak):
- Hardcoded defaults in config.py.jinja
- Users must remember to change

**Better approach** (to implement):
```jinja
# In copier.yml
secret_key:
  type: str
  default: "{{ 999999999999999999 | random | hash('sha256') }}"

# In config.py.jinja
secret_key: str = Field(
    default="{{ secret_key }}",
    description="Secret key for session encryption",
)
```

### Cursor Rules Templating Strategy
**Decision needed**:
1. Make all rules static (no .jinja) since they're generic
2. Template all rules that reference project specifics
3. Hybrid: Template only what's needed

**Recommendation**: Make CLAUDE_BBS.md static (not templated), keep general.mdc static, template only check-all-tools.mdc.jinja since it references module_name.

## Copier Update Strategy (Future)

Copier supports updating existing projects from template:
```bash
# In a generated project
copier update
```

**Not currently supported well** because:
- _skip_if_exists for README.md
- No version tags in template repo
- No documented update process

**To enable updates**:
1. Add git tags to template repo (v1.0.0, etc.)
2. Document what's safe to update
3. Test update workflow
4. Add _skip_if_exists for user-modified files

## Common Tasks

### Adding a New Template File
```bash
# 1. Create file in template/ directory
# 2. Add .jinja if it needs variable substitution
# 3. Use {{ module_name }} for Python package references
# 4. Use {{ project_name }} for display names, URLs
# 5. Test by regenerating a project

# Example:
touch template/{{module_name}}/new_module.py.jinja
# Edit file with variables
copier copy . /tmp/test --force
cat /tmp/test/my_app/new_module.py  # Verify variables substituted
```

### Adding a New Question
```yaml
# In copier.yml
new_setting:
  type: str
  help: Description shown to user
  default: reasonable_default

# Then use in templates:
# {{ new_setting }}
```

### Modifying Post-Generation Tasks
```yaml
# In copier.yml _tasks section
# Tasks run in generated directory
# Use shell syntax
# Prefix with error handling if needed:
_tasks:
  - "command || echo 'Warning: command failed'"
```

## Resources

- [Copier Documentation](https://copier.readthedocs.io/en/stable/)
- [Jinja2 Template Designer Documentation](https://jinja.palletsprojects.com/)
- Template README.md has user-facing documentation
- Generated CLAUDE.md.jinja becomes guidance for using generated projects

## Development Workflow

1. **Identify improvement needed** in generated projects
2. **Locate corresponding template file** in `template/` directory
3. **Edit template file** (add .jinja if adding variables)
4. **Test by generating project**: `copier copy . /tmp/test_proj --force`
5. **Verify changes** in generated project
6. **Update this CLAUDE.md** if architecture changes
7. **Commit with clear message** describing template change
8. **Consider versioning** if change is breaking

## Notes

- This is a personal/hobby template - not enterprise-grade
- Focus on rapid iteration and developer experience
- Trade-offs favor simplicity over comprehensive safety
- Generated projects expected to have ~100 users, ~1000 files scale
- Template targets developers comfortable with Python, PostgreSQL, and basic DevOps
