# GitHub Actions Testing Guide

This repository has automated testing set up via GitHub Actions to test the installer on fresh macOS and Ubuntu environments.

## How to View Test Results

### Method 1: Via GitHub Website (Easiest)

1. **Go to your repository on GitHub:**
   ```
   https://github.com/bennoloeffler/py_template_flyio
   ```

2. **Click on the "Actions" tab** at the top of the page
   - It's between "Pull requests" and "Projects"

3. **You'll see a list of workflow runs**
   - Each time you push to `main`, the tests run automatically
   - Each entry shows:
     - ✅ Green checkmark = tests passed
     - ❌ Red X = tests failed
     - 🟡 Yellow dot = tests running

4. **Click on any workflow run** to see details
   - Shows both macOS and Ubuntu test results
   - Click on "test-macos" or "test-ubuntu" to see full logs

5. **View the logs:**
   - Click on any step (e.g., "Run installer in check-only mode")
   - See exactly what was detected and what would be installed

### Method 2: Direct URL

After pushing, go to:
```
https://github.com/bennoloeffler/py_template_flyio/actions
```

### Method 3: Via Command Line

```bash
# Install GitHub CLI if you don't have it
brew install gh

# Login to GitHub
gh auth login

# View workflow runs
gh run list --workflow=test-installer.yml

# View specific run details
gh run view <run-id>

# Watch a run in real-time
gh run watch
```

## When Tests Run Automatically

The workflow runs automatically when:
- ✅ You push changes to the `main` branch
- ✅ Files changed: `setup-tools.sh`, `to_zshrc`, or the workflow file itself
- ✅ You create a pull request to `main`

## Manual Trigger

You can also run tests manually without pushing:

1. Go to: `https://github.com/bennoloeffler/py_template_flyio/actions`
2. Click on "Test Installer on Fresh macOS" in the left sidebar
3. Click the "Run workflow" button (top right)
4. Select branch (usually `main`)
5. Click green "Run workflow" button

## What Gets Tested

### macOS Test (Full Installation)
- ✅ Shows macOS version and pre-installed tools
- ✅ **BEFORE**: Checks what's already installed
- ✅ **INSTALL**: Runs `./setup-tools.sh` (FULL INSTALLATION)
- ✅ **AFTER**: Checks what's now installed
- ✅ **COMPARE**: Shows what was successfully installed
- ✅ **VERIFY**: Tests each critical tool actually works
- ✅ Tests downloading `to_zshrc` from GitHub

### Ubuntu Test (Full Installation)
- ✅ Shows Ubuntu version and pre-installed tools
- ✅ **BEFORE**: Checks what's already installed
- ✅ **INSTALL**: Runs `./setup-tools.sh` (FULL INSTALLATION)
- ✅ **AFTER**: Checks what's now installed
- ✅ **COMPARE**: Shows what was successfully installed
- ✅ **VERIFY**: Tests each critical tool actually works

## Understanding the Results

### Example Output

**BEFORE Installation:**
```
✓ Git is installed
✓ Python 3.11+ is installed
✗ Node.js is NOT installed
✗ npm is NOT installed
✗ uv is NOT installed
...
Installed: 8 tools
Missing: 16 tools
```

**AFTER Installation:**
```
✓ Git is installed
✓ Python 3.11+ is installed
✓ Node.js is installed
✓ npm is installed
✓ uv is installed
...
Installed: 22 tools
Missing: 2 tools
```

**Compare Results:**
```
Tools that were missing and are now installed:
Node.js
npm
uv
copier
ripgrep
...
```

**Verification:**
```
Node.js: v22.11.0
npm: 10.9.0
uv: 0.5.11
copier: 9.4.1
ruff: 0.8.4
ripgrep: 14.1.1
```

This tells you:
- ✅ What was missing before installation
- ✅ What the installer successfully installed
- ✅ That each tool actually works (not just present)
- ✅ The exact versions installed

## Troubleshooting

### If workflow doesn't appear:
1. Make sure you've pushed the `.github/workflows/test-installer.yml` file
2. Check you're looking at the correct branch (usually `main`)
3. Wait 10-30 seconds after pushing

### If tests fail:
1. Click on the failed run
2. Click on the failed job (red X)
3. Expand the failed step
4. Read the error message
5. Fix the issue in `setup-tools.sh`
6. Push the fix - tests will run again automatically

## Cost

GitHub Actions is **FREE** for public repositories:
- ✅ Unlimited minutes for public repos
- ✅ Multiple operating systems (macOS, Ubuntu, Windows)
- ✅ No credit card required

## Next Steps After Tests Pass

Once tests pass on fresh environments:
1. ✅ You know the installer works on clean machines
2. ✅ Safe to share the one-liner with others
3. ✅ Can add badge to README showing test status

### Add Status Badge (Optional)

Add this to your README.md:

```markdown
![Test Installer](https://github.com/bennoloeffler/py_template_flyio/actions/workflows/test-installer.yml/badge.svg)
```

Shows: ![Test Installer](https://github.com/bennoloeffler/py_template_flyio/actions/workflows/test-installer.yml/badge.svg)
