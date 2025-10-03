# ALL CHANGES - Complete Template Transformation Plan

## Executive Summary

Transform the minimal `py_template_flyio` Copier template into a **fully functional file-sharing web application** with user authentication, file upload/download capabilities, and a complete admin interface. The template will generate working applications that match the design vision in `template/docs/design.md.jinja`.

**Source of Truth**: Working code from `/Users/benno/projects/ai/py_template_flyio/system_praktiker/`

**Target**: Update all files in `/Users/benno/projects/ai/py_template_flyio/template/`

---

## Phase 1: Core Python Backend Files

### 1.1 Update `template/{{module_name}}/models.py.jinja`

**Status**: File does not exist - CREATE NEW

**Action**: Create comprehensive Pydantic models file based on `system_praktiker/models.py`

**Content to include**:
- User models: `UserBase`, `UserCreate`, `UserUpdate`, `UserPublic`, `UserInDB`
- User enums: `UserRole` (admin, user), `UserStatus` (active, inactive, invited)
- Authentication models: `LoginRequest`, `Token`, `TokenData`
- File models: File info for upload/download tracking
- All Pydantic validation with Field descriptors

**Template Variables Needed**:
- None (models are generic)

**Dependencies Added**: None (pydantic already in dependencies)

---

### 1.2 Rewrite `template/{{module_name}}/db.py.jinja`

**Status**: EXISTS - MAJOR OVERHAUL NEEDED

**Current State**: Simple counter example (1141 lines in system_praktiker version)

**Action**: Replace entire file with production database layer from `system_praktiker/db.py`

**Key Features to Include**:
- PostgreSQL connection pool with asyncpg
- Password hashing with bcrypt (passlib)
- User management methods:
  - `create_user(email, password, role, ...)`
  - `get_user_by_email(email)`
  - `authenticate_user(email, password)`
  - `update_user(user_id, **fields)`
  - `delete_user(user_id)`
  - `list_users()`
- File management methods (if storing in DB):
  - `create_file_record(...)`
  - `get_file_by_filename(...)`
  - `list_files(limit, offset, uploaded_by)`
  - `delete_file(file_id)`
- Database initialization with `init_db()` calling migration system

**Template Variables Needed**:
- `{{ module_name }}` for imports

**New Dependencies Required**:
- `passlib[bcrypt]` for password hashing
- `python-jose[cryptography]` for JWT tokens

---

### 1.3 Rewrite `template/{{module_name}}/db_migrate.py.jinja`

**Status**: EXISTS - COMPLETE REPLACEMENT

**Current State**: Placeholder or minimal

**Action**: Replace with JSM (Just SQL Migration) system from `system_praktiker/db_migrate.py` (799 lines)

**Key Features**:
- Migration step tracking with `migration_steps` table
- Automatic backup of data tables before alterations
- Single transaction safety (rollback on failure)
- Migration step definitions with:
  - Step number (0, 1, 2...)
  - Tables to backup
  - SQL DDL and data copy operations
- Initial migration (step 0) creates:
  - `users` table with all fields
  - `files` table with BYTEA storage
  - Indexes and constraints
  - Admin user creation

**Template Variables Needed**:
- `{{ module_name }}` for imports and config

**Critical**: Include admin user creation in step 0:
```python
# After table creation, create initial admin
INSERT INTO users (email, password_hash, role, status, full_name)
VALUES ('admin@{{ project_name }}.local', '<HASHED>', 'admin', 'active', 'Administrator')
```

---

### 1.4 Update `template/{{module_name}}/config.py.jinja`

**Status**: EXISTS - NEEDS ENHANCEMENT

**Current State**: Basic settings

**Action**: Enhance with additional fields from `system_praktiker/config.py`

**Add These Fields**:
```python
# JWT Token Configuration
access_token_expire_minutes: int = Field(
    default=43200,  # 30 days
    description="JWT token expiration time in minutes"
)
token_refresh_threshold: float = Field(
    default=0.5,
    description="Refresh token when 50% of lifetime has passed"
)

# File Upload Configuration
max_file_size_mb: int = Field(default=10, description="Max file size in MB")
allowed_file_types: List[str] = Field(
    default=["image/jpeg", "image/png", "application/pdf", ...],
    description="Allowed MIME types for uploads"
)
```

**Template Variables Needed**:
- All existing variables preserved

---

### 1.5 Create `template/{{module_name}}/upload_files.py.jinja`

**Status**: File does not exist - CREATE NEW

**Action**: Create file upload service from `system_praktiker/upload_files.py` (529 lines)

**Key Features**:
- `FileService` class with dependency injection
- Upload with unique filename generation (file_001.jpg, file_002.jpg)
- BYTEA storage in PostgreSQL
- File validation (type, size)
- Thumbnail generation for images (SMALL, VERY_SMALL)
- Download with proper MIME types
- List files with pagination
- Delete files with permission checks

**Template Variables Needed**:
- `{{ module_name }}` for imports

**New Dependencies Required**:
- `Pillow` for image processing

---

### 1.6 Rewrite `template/{{module_name}}/main.py.jinja`

**Status**: EXISTS - COMPLETE REPLACEMENT NEEDED

**Current State**: Simple counter app (2543 lines in system_praktiker)

**Action**: Replace with full FastAPI application

**Key Components**:

#### Authentication & Authorization
- JWT token creation with `create_access_token()`
- User authentication with `authenticate_user()`
- Current user dependency: `get_current_user_hybrid()` (supports Bearer + Cookie)
- Role checking: `require_admin()` dependency
- Password validation: `validate_password()`

#### API Endpoints - Authentication
```python
POST /api/register - Create new user account
POST /api/login - Login and get JWT token
POST /api/logout - Logout (clear cookie)
GET /api/me - Get current user info
PUT /api/users/me - Update own profile
DELETE /api/users/me - Delete own account
POST /api/change-password - Change password
```

#### API Endpoints - File Operations
```python
POST /api/files/upload - Upload file (authenticated)
GET /api/files - List files with pagination
GET /api/files/{filename} - Download file (public)
DELETE /api/files/{file_id} - Delete own file (user) or any file (admin)
```

#### API Endpoints - Admin
```python
GET /api/admin/users - List all users (admin only)
DELETE /api/admin/users/{user_id} - Delete user (admin only)
DELETE /api/admin/files/{file_id} - Delete any file (admin only)
```

#### HTML Page Routes
```python
GET / - Landing page with hero
GET /login - Login page
GET /register - Registration page
GET /files - File browser page
GET /upload - File upload page (authenticated)
GET /admin - Admin dashboard (admin only)
```

#### Middleware & Configuration
- CORS middleware with allowed origins
- Rate limiting with slowapi
- Static file serving (`/static`)
- Jinja2 template rendering
- Lifespan context for DB connection

**Template Variables Needed**:
- `{{ module_name }}` throughout for imports and paths

**New Dependencies Required**:
- `slowapi` for rate limiting
- `python-jose[cryptography]` for JWT
- `python-multipart` for file uploads

---

## Phase 2: Frontend Templates & Static Files

### 2.1 Create `template/{{module_name}}/html_templates/` Directory Structure

**Action**: Create complete HTML template hierarchy

**Files to Create** (from system_praktiker):

#### Base Templates
- `base.html.jinja` - Master template with:
  - Tailwind CSS CDN
  - Google Fonts (Inter)
  - Navigation bar with user menu
  - Flash message system
  - Authentication state handling
  - Footer with links

#### Authentication Pages
- `login.html.jinja` - Login form with email/password
- `register.html.jinja` - Registration form
- `password-reset.html.jinja` - Password reset flow

#### Main Application Pages
- `index.html.jinja` - Landing page with hero section
- `files.html.jinja` - File browser/gallery view
- `upload_files.html.jinja` - File upload interface with drag-drop

#### Admin Pages
- `admin-dashboard.html.jinja` - Admin overview
- `admin-users.html.jinja` - User management table
- `admin-files.html.jinja` - File management table

#### Utility Pages
- `error.html.jinja` - Error page template
- `impressum.html.jinja` - Legal imprint
- `datenschutz.html.jinja` - Privacy policy

**Template Variables in HTML**:
- `{{ module_name }}` for API endpoints
- `{{ project_name }}` for display names
- `{{ app_title }}` from settings

---

### 2.2 Create `template/{{module_name}}/html_templates/components/` Directory

**Action**: Create reusable HTML components

**Components to Create**:
- `file_picker.html` - File selection modal/widget
- `media-preview.html` - Image/PDF preview component
- `admin-actions.html` - Admin action buttons
- `admin-confirm-modal.html` - Confirmation dialogs
- `hero-background-carousel.html` - Landing page hero

---

### 2.3 Create `template/{{module_name}}/static/` Directory Structure

**Action**: Create static assets directory

**Structure**:
```
{{module_name}}/static/
├── auth.js              # Authentication JS (login, register, token refresh)
├── components/
│   ├── file_picker.js   # File picker widget logic
│   ├── media-preview.js # Media preview logic
│   └── admin-components.js # Admin UI interactions
├── images/              # Project-specific images
└── favicon.ico          # Favicon
```

**Key JavaScript Files**:

#### `auth.js` - Authentication Logic
- JWT token storage in cookies
- Token refresh logic (when 50% expired)
- Login form submission
- Registration form submission
- Logout functionality
- Auth state UI updates

#### `components/file_picker.js` - File Picker Component
- File browser modal
- File selection handling
- Preview generation
- URL insertion into forms

#### `components/media-preview.js` - Media Preview
- Image preview with lightbox
- PDF preview with iframe
- File download handling

---

## Phase 3: Documentation Updates

### 3.1 Update `template/CLAUDE.md.jinja`

**Status**: EXISTS - MAJOR UPDATE NEEDED

**Action**: Rewrite to reflect actual file-sharing application

**Remove References To**:
- Generic "file uploads" - be specific
- Features not in base template (events, companies, map)
- CLAUDE_BBS.md (handle separately)

**Add Sections**:
- **Authentication System**: JWT tokens, role-based access (admin/user)
- **File Upload Architecture**: BYTEA storage, unique filenames, thumbnails
- **Database Schema**: Users table, Files table, migrations
- **API Endpoints**: Complete list of /api/* endpoints
- **Frontend Components**: HTML templates, JavaScript modules
- **Development Workflow**:
  - Server logs in `server.log`
  - Test with curl examples
  - Admin access setup

**Template Variables**:
- `{{ module_name }}` for all code references
- `{{ project_name }}` for display names

---

### 3.2 Update `template/docs/design.md.jinja`

**Status**: EXISTS - ALREADY GOOD

**Action**: Minor enhancements only

**Current Content** (from review):
```
Users: may be admins, users and visitors.
users may upload files, download files from all users and delete their own files.
visitors may search, view and download files from all users.
admins may also in addition delete users and files from all users)

Files: upload all sorts of text and binary files like md, docx, pdf, ...
```

**Add**:
- Data model diagram
- API endpoint map
- Authentication flow diagram
- File upload/download sequence

---

### 3.3 Update `template/docs/requirements.md.jinja`

**Status**: EXISTS - NEEDS MAJOR EXPANSION

**Current State**: Nearly empty shell

**Action**: Document complete tech stack and requirements

**Add**:

#### Tech Stack
```markdown
## Backend
- Python 3.11+
- FastAPI for web framework
- asyncpg for PostgreSQL async driver
- Pydantic for data validation
- python-jose for JWT tokens
- passlib[bcrypt] for password hashing
- Pillow for image processing
- slowapi for rate limiting

## Frontend
- HTML5 with Jinja2 templating
- Tailwind CSS (CDN)
- Vanilla JavaScript (no framework)
- Google Fonts (Inter)

## Database
- PostgreSQL 14+
- BYTEA for file storage
- Full migration system (JSM)

## Deployment
- Docker with uv package manager
- Fly.io platform
- PostgreSQL on Fly.io
```

#### Data Model
```markdown
## Users Table
- id, email (unique), password_hash
- role: admin | user
- status: active | inactive | invited
- full_name, phone_number, company_name, address
- about_me, about_company
- portrait_url (for profile image)
- created_at, updated_at

## Files Table
- id, filename (unique), original_filename
- content_type, file_size
- data (BYTEA - file content)
- uploaded_by (FK to users)
- thumbnail_type: SMALL | VERY_SMALL | NULL
- parent_file_id (for thumbnails)
- created_at, is_active
```

#### API Documentation
- Complete endpoint list
- Request/response examples
- Authentication requirements
- Error responses

---

### 3.4 Handle `template/CLAUDE_BBS.md`

**Status**: Static file, not templated

**Action**: Either remove or make project-specific

**Options**:
1. **Remove entirely** - BBS principles documented in main CLAUDE.md
2. **Keep as-is** - Generic architecture guidance
3. **Template it** - Make it `.jinja` and customize per project

**Recommendation**: Keep as-is (generic is fine for architecture principles)

---

### 3.5 Clean Up `template/docs/features_concepts/`

**Status**: Contains many example features not in base template

**Action**: Remove or reorganize

**Current Files** (examples from system_praktiker):
- cookie_banner_gdpr_concept.md
- feature_uploads_thumbnails.md
- hero-background-carousel.md
- markdown-view.md
- onboarding_flow.md
- password_reset.md
- pdf_preview_timeout.md
- send_email.md
- ui_design.md

**Decision**:
- **Keep** as examples: `feature_uploads_thumbnails.md`, `password_reset.md`
- **Remove** system_praktiker-specific: `cookie_banner_gdpr_concept.md`, others
- **Add** base template features: `user_authentication.md`, `file_storage.md`, `admin_panel.md`

---

## Phase 4: Configuration & Build Files

### 4.1 Update `copier.yml`

**Status**: EXISTS - NEEDS UPDATES

**Changes Required**:

#### Update Default Dependencies
```yaml
dependencies:
  type: str
  help: Dependencies (comma-separated list)
  default: "pydantic, pydantic-settings, fastapi[all], uvicorn, slowapi, httpx, asyncpg, passlib[bcrypt], python-jose[cryptography], python-multipart, Pillow"
```

#### Update Dev Dependencies
```yaml
development_dependencies:
  type: str
  help: Development dependencies (comma-separated list)
  default: "pytest, pytest-watch, pytest-asyncio, black, ruff, mypy, httpx"
```

#### Fix _tasks Section
```yaml
_tasks:
  # 1. Create databases (may fail if not running - that's OK)
  - "createdb -U postgres -h localhost -p 5432 {{ module_name }} || true"
  - "createdb -U postgres -h localhost -p 5432 {{ module_name }}_test || true"

  # 2. Create virtual environment
  - "uv venv"

  # 3. Initialize git (before sync so .gitignore works)
  - "git init"

  # 4. Install dependencies
  - "source .venv/bin/activate && uv sync --extra dev"

  # 5. Run quality checks (will show what needs fixing)
  - "./check.sh || true"

  # NOTE: Do NOT add 'git add .' - let user review first
  # NOTE: Fly.io setup is manual - see README.md
```

---

### 4.2 Update `template/pyproject.toml.jinja`

**Status**: EXISTS - UPDATE DEPENDENCIES

**Changes**:
- Ensure all new dependencies listed
- Add proper mypy configuration
- Update ruff rules for FastAPI

**Add**:
```toml
[tool.mypy]
plugins = ["pydantic.mypy"]
ignore_missing_imports = true

[tool.ruff.lint]
select = ["E", "F", "I"]
ignore = ["E501"]  # Line too long (handled by black)
```

---

### 4.3 Update `template/README.md.jinja`

**Status**: EXISTS - COMPLETE REWRITE

**Current State**: Generic template info

**Action**: Write README for file-sharing application

**Structure**:
```markdown
# {{ project_name }}

File sharing web application with user authentication.

## Features

- 🔐 User authentication (JWT tokens)
- 📁 File upload/download with thumbnails
- 👥 User management (admin/user roles)
- 🖼️ Image preview and galleries
- 📄 Support for PDF, images, documents
- 🛡️ Role-based access control
- 🚀 Ready for Fly.io deployment

## Quick Start

### Prerequisites
- Python 3.11+
- PostgreSQL 14+
- uv package manager

### Development

# Run server
uv run uvicorn {{ module_name }}.main:app --reload --port 8877

# Run tests
uv run pytest

# Quality checks
./check.sh

### First Login

Default admin account:
- Email: admin@{{ project_name }}.local
- Password: [check .env or config.py]

### Deployment to Fly.io

See deployment guide in docs/deployment.md

## Project Structure

{{ module_name }}/
├── main.py          # FastAPI application
├── db.py            # Database layer
├── models.py        # Pydantic models
├── upload_files.py  # File handling
├── html_templates/  # Jinja2 templates
└── static/          # CSS, JS, images

## API Documentation

Once running, visit:
- API docs: http://localhost:8877/docs
- File browser: http://localhost:8877/files
- Admin panel: http://localhost:8877/admin
```

---

### 4.4 Update `template/.env.example.jinja`

**Status**: EXISTS - NEEDS EXPANSION

**Add**:
```bash
# Application
APP_TITLE={{ project_name }}
ENVIRONMENT=development
DEBUG=true

# Database
DATABASE_URL=postgresql://postgres:postgres@localhost/{{ module_name }}
DATABASE_TEST_URL=postgresql://postgres:postgres@localhost/{{ module_name }}_test

# Security - CHANGE THESE IN PRODUCTION!
SECRET_KEY=change-me-in-production-use-random-string
ADMIN_PASSWORD=admin123

# JWT Configuration
ACCESS_TOKEN_EXPIRE_MINUTES=43200  # 30 days

# File Upload
MAX_FILE_SIZE_MB=10

# Optional: External Services
# OPENAI_API_KEY=your-key-here
```

---

### 4.5 Create `template/.gitignore.jinja`

**Status**: EXISTS - VERIFY COMPLETENESS

**Ensure Includes**:
```
# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
*.egg-info/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Testing
.pytest_cache/
.coverage
htmlcov/

# Logs
*.log
server.log

# Database
*.db
*.sqlite

# Fly.io
.fly/
```

---

## Phase 5: Testing

### 5.1 Update `template/tests/test_main.py.jinja`

**Status**: EXISTS - NEEDS COMPLETE REWRITE

**Current State**: Simple counter tests

**Action**: Create comprehensive test suite

**Test Categories**:

#### Authentication Tests
```python
async def test_register_user()
async def test_login_user()
async def test_login_invalid_credentials()
async def test_get_current_user()
async def test_admin_access_required()
```

#### File Upload Tests
```python
async def test_upload_file_authenticated()
async def test_upload_file_unauthenticated_fails()
async def test_upload_file_too_large_fails()
async def test_upload_file_invalid_type_fails()
async def test_download_file_public()
async def test_list_files()
```

#### User Management Tests
```python
async def test_update_own_profile()
async def test_delete_own_account()
async def test_admin_delete_user()
async def test_user_cannot_delete_other_users()
```

**Testing Infrastructure**:
- Use pytest-asyncio
- Database fixtures (test database)
- Authentication fixtures (mock users)
- File upload fixtures (test files)

---

### 5.2 Create `template/tests/test_db.py.jinja`

**Status**: File does not exist - CREATE NEW

**Action**: Create database layer tests

**Tests**:
```python
async def test_create_user()
async def test_authenticate_user()
async def test_password_hashing()
async def test_get_user_by_email()
async def test_update_user()
async def test_delete_user()
```

---

### 5.3 Create `template/tests/test_upload_files.py.jinja`

**Status**: File does not exist - CREATE NEW

**Action**: Create file service tests

**Tests**:
```python
async def test_unique_filename_generation()
async def test_thumbnail_creation()
async def test_file_validation()
async def test_file_metadata()
```

---

### 5.4 Create `template/tests/conftest.py.jinja`

**Status**: File does not exist - CREATE NEW

**Action**: Create pytest configuration and fixtures

**Fixtures**:
```python
@pytest.fixture
async def test_db():
    """Test database with clean state"""

@pytest.fixture
async def test_client():
    """FastAPI test client"""

@pytest.fixture
async def admin_token():
    """JWT token for admin user"""

@pytest.fixture
async def user_token():
    """JWT token for regular user"""

@pytest.fixture
def test_image():
    """Sample image file for upload tests"""
```

---

## Phase 6: Deployment & Scripts

### 6.1 Review Deployment Scripts

**Files**:
- `template/fly_deploy_test.sh` - EXISTS, review
- `template/fly_deploy_prod.sh` - EXISTS, review
- `template/fly_launch_to_flyio.sh.jinja` - EXISTS, review

**Action**: Verify scripts work with new application structure

**Check**:
- Git tagging logic
- Build process
- Environment variable handling
- Volume mounting for file storage (if needed)

---

### 6.2 Update `template/Dockerfile.jinja`

**Status**: EXISTS - VERIFY COMPATIBILITY

**Current Dockerfile**:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# Copy project files
COPY . .
# Install dependencies
RUN /root/.local/bin/uv venv && \
    /root/.local/bin/uv sync
# Expose port
EXPOSE 8080
# Run application
CMD ["/app/.venv/bin/uvicorn", "{{ module_name }}.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

**Potential Issues**:
- File storage: If using BYTEA, no volumes needed
- If using filesystem, need volume mount

**Action**: Verify and document in comments

---

### 6.3 Create Fly.io Configuration Guide

**Action**: Create `template/docs/deployment.md.jinja`

**Content**:
```markdown
# Deployment Guide for {{ project_name }}

## Fly.io Deployment

### Prerequisites
- Fly.io account and CLI installed
- PostgreSQL database on Fly.io

### Step 1: Launch App

./fly_launch_to_flyio.sh.jinja

### Step 2: Create Database

flyctl postgres create --name {{ project_name }}-db

### Step 3: Set Secrets

flyctl secrets set SECRET_KEY="<random-string>"
flyctl secrets set ADMIN_PASSWORD="<secure-password>"
flyctl secrets set DATABASE_URL="<postgres-url>"

### Step 4: Deploy

./fly_deploy_prod.sh

### Post-Deployment

1. Visit https://{{ project_name }}.fly.dev
2. Login with admin credentials
3. Create additional users
```

---

## Phase 7: Final Consistency & Polish

### 7.1 Consistency Checklist

**Ensure Consistency Across**:

#### Template Variable Usage
- [ ] All Python imports use `{{ module_name }}`
- [ ] All display names use `{{ project_name }}`
- [ ] Database names use `{{ module_name }}` (underscores)
- [ ] URLs use `{{ project_name }}` (hyphens)

#### File Naming
- [ ] All templated files end in `.jinja`
- [ ] No `.jinja` files that don't need templating
- [ ] Template directory structure matches generated structure

#### Documentation
- [ ] CLAUDE.md references actual features only
- [ ] README matches actual application
- [ ] design.md matches implementation
- [ ] requirements.md lists all dependencies
- [ ] All example features removed or marked as examples

#### Code Quality
- [ ] All Python files pass mypy
- [ ] All Python files pass ruff
- [ ] All Python files formatted with black
- [ ] All tests pass

---

### 7.2 Create Validation Script

**Action**: Create `template/validate_template.sh`

**Purpose**: Test template generation before committing

**Content**:
```bash
#!/bin/bash
# Validate Copier template by generating a test project

set -e

echo "🧪 Validating py_template_flyio template..."

# Generate test project
TEMP_DIR=$(mktemp -d)
echo "📁 Generating to: $TEMP_DIR"

cd "$(dirname "$0")/.."
copier copy . "$TEMP_DIR/test_project" --defaults

# Navigate to generated project
cd "$TEMP_DIR/test_project"

# Check structure
echo "✓ Project generated"

# Try to run checks
if [ -f "check.sh" ]; then
    ./check.sh || echo "⚠️  Some checks failed (expected on first run)"
fi

# Try to import main module
python -c "import sys; sys.path.insert(0, '.'); import test_project.main" || \
    echo "⚠️  Import check failed"

echo "✅ Template validation complete"
echo "📁 Test project at: $TEMP_DIR/test_project"
echo "💡 Review manually, then: rm -rf $TEMP_DIR"
```

---

### 7.3 Update Root CLAUDE.md

**Status**: EXISTS (just created) - ADD SECTION

**Action**: Add section about template validation

**Add to CLAUDE.md**:
```markdown
## Validating Template Changes

After making changes to the template, validate before committing:

### Quick Validation
copier copy . /tmp/test_proj --defaults
cd /tmp/test_proj
./check.sh

### Full Validation
./template/validate_template.sh

### Test Actual Usage
copier copy . /tmp/real_test
# Answer prompts as real user would
cd /tmp/real_test
# Follow README.md setup
# Verify application works
```

---

## Phase 8: Migration Strategy

### 8.1 Update Strategy for Existing Template Users

**Problem**: Users who already generated projects from old template

**Solution**: Provide migration guide

**Action**: Create `MIGRATION_GUIDE.md` in repository root

**Content**:
```markdown
# Migration Guide - Template v1.0 to v2.0

## What Changed

Template v2.0 is a complete rewrite, transforming from a simple counter app to a full file-sharing application.

## For Existing Projects

### Option 1: Start Fresh (Recommended)
1. Generate new project from v2.0 template
2. Migrate custom code manually
3. Update database with new schema

### Option 2: Manual Update
Not recommended due to extensive changes.

## For New Projects

Use template v2.0:
copier copy https://github.com/bennoloeffler/py_template_flyio.git my_project
```

---

## Summary of Files to Create/Modify

### Create New Files (23 files)

**Python Backend** (5 files):
1. `template/{{module_name}}/models.py.jinja` ⭐
2. `template/{{module_name}}/upload_files.py.jinja` ⭐
3. `template/tests/test_db.py.jinja`
4. `template/tests/test_upload_files.py.jinja`
5. `template/tests/conftest.py.jinja`

**HTML Templates** (13 files):
6. `template/{{module_name}}/html_templates/base.html.jinja` ⭐
7. `template/{{module_name}}/html_templates/index.html.jinja`
8. `template/{{module_name}}/html_templates/login.html.jinja`
9. `template/{{module_name}}/html_templates/register.html.jinja`
10. `template/{{module_name}}/html_templates/files.html.jinja`
11. `template/{{module_name}}/html_templates/upload_files.html.jinja` ⭐
12. `template/{{module_name}}/html_templates/admin-dashboard.html.jinja`
13. `template/{{module_name}}/html_templates/admin-users.html.jinja`
14. `template/{{module_name}}/html_templates/error.html.jinja`
15. `template/{{module_name}}/html_templates/components/file_picker.html`
16. `template/{{module_name}}/html_templates/components/media-preview.html`
17. `template/{{module_name}}/html_templates/components/admin-actions.html`
18. `template/{{module_name}}/html_templates/components/hero-background-carousel.html`

**JavaScript/Static** (3 files):
19. `template/{{module_name}}/static/auth.js` ⭐
20. `template/{{module_name}}/static/components/file_picker.js`
21. `template/{{module_name}}/static/components/media-preview.js`

**Documentation** (2 files):
22. `template/docs/deployment.md.jinja`
23. `template/validate_template.sh`

### Modify Existing Files (12 files)

**Python Backend** (3 files):
1. `template/{{module_name}}/main.py.jinja` ⭐⭐⭐ (complete rewrite)
2. `template/{{module_name}}/db.py.jinja` ⭐⭐⭐ (complete rewrite)
3. `template/{{module_name}}/db_migrate.py.jinja` ⭐⭐ (complete rewrite)
4. `template/{{module_name}}/config.py.jinja` ⭐ (enhance)

**Testing** (1 file):
5. `template/tests/test_main.py.jinja` ⭐⭐ (rewrite)

**Configuration** (4 files):
6. `copier.yml` ⭐ (update dependencies and tasks)
7. `template/pyproject.toml.jinja` (update dependencies)
8. `template/.env.example.jinja` (add new vars)
9. `template/.gitignore.jinja` (verify)

**Documentation** (4 files):
10. `template/README.md.jinja` ⭐⭐ (complete rewrite)
11. `template/CLAUDE.md.jinja` ⭐⭐ (major update)
12. `template/docs/design.md.jinja` (minor enhancements)
13. `template/docs/requirements.md.jinja` ⭐ (major expansion)

**Root Files** (1 file):
14. `CLAUDE.md` (add validation section)

### Delete Files (1 file)
1. `template/{{module_name}}/html_templates/counter.html.jinja` (old example)

---

## Priority Order for Implementation

### P0 - Critical Path (Must Have Working App)
1. ⭐⭐⭐ `main.py.jinja` - Core application
2. ⭐⭐⭐ `db.py.jinja` - Database layer
3. ⭐⭐⭐ `db_migrate.py.jinja` - Schema initialization
4. ⭐⭐ `models.py.jinja` - Data models
5. ⭐⭐ `upload_files.py.jinja` - File handling
6. ⭐⭐ `base.html.jinja` - Template foundation
7. ⭐⭐ `copier.yml` - Template configuration

### P1 - Essential Features
8. ⭐ `login.html.jinja` - Authentication UI
9. ⭐ `register.html.jinja` - Registration UI
10. ⭐ `upload_files.html.jinja` - Upload UI
11. ⭐ `auth.js` - Frontend auth logic
12. ⭐ `README.md.jinja` - User documentation
13. ⭐ `CLAUDE.md.jinja` - AI assistant guidance

### P2 - Polish & Completeness
14. Admin pages and components
15. Additional HTML templates
16. JavaScript components
17. Test files
18. Deployment documentation

---

## Validation Criteria

### Template Generation Must:
- [ ] Generate project without errors
- [ ] Pass all quality checks (./check.sh)
- [ ] Create valid Python package structure
- [ ] Include all required dependencies in pyproject.toml
- [ ] Create .env.example with all needed vars

### Generated Application Must:
- [ ] Start without errors (uvicorn command)
- [ ] Initialize database on first run
- [ ] Create admin user automatically
- [ ] Serve login page at http://localhost:8877/login
- [ ] Serve file browser at http://localhost:8877/files
- [ ] Allow file upload when authenticated
- [ ] Allow file download (public)
- [ ] Show admin panel when logged in as admin

### Tests Must:
- [ ] All pytest tests pass
- [ ] mypy type checking passes
- [ ] ruff linting passes
- [ ] black formatting check passes

### Documentation Must:
- [ ] README accurately describes generated app
- [ ] CLAUDE.md references actual features only
- [ ] API endpoints documented
- [ ] Deployment steps clear

---

## Risk Mitigation

### Risks & Mitigation:

**Risk**: Template too complex for users to understand
- **Mitigation**: Comprehensive documentation, examples, clear comments

**Risk**: Template variables incorrectly applied
- **Mitigation**: Test generation multiple times with different inputs

**Risk**: Dependencies conflict or missing
- **Mitigation**: Test with fresh virtual environment, document all deps

**Risk**: Database migration fails on first run
- **Mitigation**: Extensive testing, clear error messages, rollback safety

**Risk**: Generated code doesn't pass quality checks
- **Mitigation**: Run check.sh on template itself, fix before release

**Risk**: Breaking changes for existing template users
- **Mitigation**: Version bump to 2.0, provide migration guide, announce clearly

---

## Timeline Estimate

**Phase 1 - Core Backend**: 6-8 hours
- Create/update all Python files
- Get basic app running

**Phase 2 - Frontend**: 4-6 hours
- Create HTML templates
- Add JavaScript components

**Phase 3 - Documentation**: 2-3 hours
- Update all docs
- Create deployment guide

**Phase 4 - Testing**: 3-4 hours
- Write comprehensive tests
- Validate template generation

**Phase 5 - Polish**: 2-3 hours
- Fix issues
- Improve consistency
- Final validation

**Total**: 17-24 hours (2-3 full days)

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Set up development branch** for template work
3. **Begin Phase 1** (Core Backend)
4. **Test frequently** (generate projects often)
5. **Iterate based on testing**
6. **Document as you go**
7. **Final validation** before merge
8. **Release as v2.0** with announcement

---

## Notes

- Keep backup of current template (`git tag v1.0`)
- Test on clean machine before release
- Consider creating video walkthrough
- Update GitHub README with new features
- Consider creating example generated project in separate repo

---

*End of Plan Document*
