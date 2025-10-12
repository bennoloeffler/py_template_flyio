#!/bin/bash
#
# setup-tools.sh - Install all required tools for py_template_flyio
#
# This script checks for and installs all tools needed to:
# 1. Use the Copier template
# 2. Develop generated projects
# 3. Deploy to Fly.io
#
# Usage:
#   ./setup-tools.sh              # Check and install all tools
#   ./setup-tools.sh --check-only # Only check, don't install
#
# Supports: macOS (Homebrew), Linux (apt/dnf)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
CHECK_ONLY=false
if [[ "$1" == "--check-only" ]]; then
    CHECK_ONLY=true
fi

# Track what needs to be installed
declare -a MISSING_TOOLS=()
declare -a INSTALLED_TOOLS=()

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PACKAGE_MANAGER="brew"
    elif [[ -f /etc/debian_version ]]; then
        OS="linux"
        PACKAGE_MANAGER="apt"
    elif [[ -f /etc/redhat-release ]]; then
        OS="linux"
        PACKAGE_MANAGER="dnf"
    else
        OS="unknown"
        PACKAGE_MANAGER="unknown"
    fi
}

# Print section header
print_section() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check tool and record status
check_tool() {
    local tool_name=$1
    local command_to_check=$2

    if command_exists "$command_to_check"; then
        echo -e "${GREEN}✓${NC} $tool_name is installed"
        INSTALLED_TOOLS+=("$tool_name")
        return 0
    else
        echo -e "${RED}✗${NC} $tool_name is NOT installed"
        MISSING_TOOLS+=("$tool_name")
        return 1
    fi
}

# Install Homebrew (macOS)
install_homebrew() {
    if [[ "$OS" != "macos" ]]; then
        return
    fi

    if ! command_exists brew; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Install tool based on OS
install_tool() {
    local tool_name=$1
    local brew_package=$2
    local apt_package=$3
    local dnf_package=${4:-$apt_package}
    local custom_install=$5

    echo -e "\n${YELLOW}Installing $tool_name...${NC}"

    # Use custom install function if provided
    if [[ -n "$custom_install" ]]; then
        eval "$custom_install"
        return
    fi

    # Standard package manager installation
    case "$PACKAGE_MANAGER" in
        brew)
            brew install "$brew_package"
            ;;
        apt)
            sudo apt-get update
            sudo apt-get install -y "$apt_package"
            ;;
        dnf)
            sudo dnf install -y "$dnf_package"
            ;;
        *)
            echo -e "${RED}Unsupported package manager. Please install $tool_name manually.${NC}"
            return 1
            ;;
    esac
}

# Custom installation functions
install_uv() {
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
}

install_copier() {
    if command_exists uv; then
        uv tool install copier
    elif command_exists pipx; then
        pipx install copier
    else
        echo -e "${YELLOW}Installing pipx first...${NC}"
        if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
            brew install pipx
            pipx ensurepath
        else
            python3 -m pip install --user pipx
            python3 -m pipx ensurepath
        fi
        pipx install copier
    fi
}

install_flyctl() {
    if [[ "$OS" == "macos" ]]; then
        brew install flyctl
    else
        curl -L https://fly.io/install.sh | sh
        export PATH="$HOME/.fly/bin:$PATH"
    fi
}

install_llm() {
    if command_exists uv; then
        uv tool install llm
    elif command_exists pipx; then
        pipx install llm
    else
        python3 -m pip install --user llm
    fi
}

install_ruff() {
    if command_exists uv; then
        # Ruff will be installed per-project via uv
        echo "Ruff will be installed per-project via uv"
    else
        if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
            brew install ruff
        else
            python3 -m pip install --user ruff
        fi
    fi
}

install_postgres_app() {
    local download_url="https://github.com/PostgresApp/PostgresApp/releases/latest/download/Postgres.dmg"
    local dmg_path="/tmp/Postgres.dmg"
    local mount_point="/Volumes/Postgres"

    echo -e "${YELLOW}Downloading Postgres.app...${NC}"
    curl -L -o "$dmg_path" "$download_url"

    echo -e "${YELLOW}Mounting DMG...${NC}"
    hdiutil attach "$dmg_path" -nobrowse -quiet

    echo -e "${YELLOW}Installing Postgres.app to /Applications...${NC}"
    cp -R "$mount_point/Postgres.app" /Applications/

    echo -e "${YELLOW}Unmounting DMG...${NC}"
    hdiutil detach "$mount_point" -quiet

    echo -e "${YELLOW}Cleaning up...${NC}"
    rm "$dmg_path"

    # Add to PATH in shell configs
    local postgres_path='/Applications/Postgres.app/Contents/Versions/latest/bin'

    echo -e "\n${GREEN}✓ Postgres.app installed!${NC}"
    echo -e "${YELLOW}Adding PostgreSQL to PATH...${NC}"

    # Add to .zshrc if exists (default on modern macOS)
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "$postgres_path" "$HOME/.zshrc"; then
            echo "export PATH=\"$postgres_path:\$PATH\"" >> "$HOME/.zshrc"
            echo "  - Added to ~/.zshrc"
        fi
    fi

    # Add to .bash_profile if exists
    if [[ -f "$HOME/.bash_profile" ]]; then
        if ! grep -q "$postgres_path" "$HOME/.bash_profile"; then
            echo "export PATH=\"$postgres_path:\$PATH\"" >> "$HOME/.bash_profile"
            echo "  - Added to ~/.bash_profile"
        fi
    fi

    # Export for current session
    export PATH="$postgres_path:$PATH"

    echo -e "\n${BLUE}Next steps for Postgres.app:${NC}"
    echo "  1. Open Postgres.app from Applications folder"
    echo "  2. Click 'Initialize' to create default databases"
    echo "  3. The app will run in menu bar (auto-starts on login)"
    echo "  4. Restart your terminal to update PATH"
}

install_vscode() {
    if [[ "$OS" == "macos" ]]; then
        # Homebrew cask automatically sets up 'code' command
        brew install --cask visual-studio-code

        echo -e "\n${GREEN}✓ VS Code installed!${NC}"
        echo -e "${BLUE}The 'code' command is automatically available in your terminal.${NC}"
    else
        # Linux - recommend official packages
        echo -e "${YELLOW}Installing VS Code for Linux...${NC}"

        if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
            # Debian/Ubuntu
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg

            sudo apt update
            sudo apt install -y code
        elif [[ "$PACKAGE_MANAGER" == "dnf" ]]; then
            # Fedora/RHEL
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

            sudo dnf check-update
            sudo dnf install -y code
        fi

        echo -e "\n${GREEN}✓ VS Code installed!${NC}"
        echo -e "${BLUE}The 'code' command should be available in your terminal.${NC}"
    fi
}

# Main installation flow
main() {
    print_section "py_template_flyio - Tool Setup"

    detect_os
    echo "Detected OS: $OS"
    echo "Package Manager: $PACKAGE_MANAGER"

    if [[ "$PACKAGE_MANAGER" == "unknown" ]]; then
        echo -e "${RED}Unsupported operating system. Please install tools manually.${NC}"
        exit 1
    fi

    print_section "Checking Required Tools"

    # Core tools
    echo -e "\n${BLUE}Core Tools (Required):${NC}"
    check_tool "Git" "git"
    check_tool "Python 3.11+" "python3"
    check_tool "uv (Python package installer)" "uv"
    check_tool "Copier (Template engine)" "copier"
    check_tool "PostgreSQL" "psql"
    check_tool "VS Code (code CLI)" "code"

    # Development tools
    echo -e "\n${BLUE}Development Tools (Required for generated projects):${NC}"
    check_tool "Ruff (Linter)" "ruff"
    check_tool "Black (Formatter)" "black" || true  # Will be installed via uv per-project
    check_tool "Mypy (Type checker)" "mypy" || true  # Will be installed via uv per-project
    check_tool "Pytest (Testing)" "pytest" || true  # Will be installed via uv per-project

    # Deployment tools
    echo -e "\n${BLUE}Deployment Tools (Optional):${NC}"
    check_tool "Docker" "docker"
    check_tool "Flyctl (Fly.io CLI)" "flyctl"
    check_tool "llm (AI CLI for changelogs)" "llm"

    # Shell enhancement tools
    echo -e "\n${BLUE}Shell Enhancement Tools (from to_zshrc):${NC}"
    check_tool "eza (modern ls)" "eza" || true
    check_tool "trash (safe delete)" "trash" || true
    check_tool "thefuck (command correction)" "thefuck" || true
    check_tool "fzf (fuzzy finder)" "fzf" || true
    check_tool "fd (modern find)" "fd" || true
    check_tool "bat (cat with syntax)" "bat" || true
    check_tool "tree (directory tree)" "tree" || true
    check_tool "pyenv (Python version manager)" "pyenv" || true

    # Summary
    print_section "Summary"
    echo -e "Installed: ${GREEN}${#INSTALLED_TOOLS[@]}${NC} tools"
    echo -e "Missing: ${RED}${#MISSING_TOOLS[@]}${NC} tools"

    if [[ ${#MISSING_TOOLS[@]} -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All tools are installed!${NC}"
        exit 0
    fi

    if [[ "$CHECK_ONLY" == true ]]; then
        echo -e "\n${YELLOW}Missing tools:${NC}"
        printf '%s\n' "${MISSING_TOOLS[@]}"
        echo -e "\nRun without --check-only to install missing tools."
        exit 1
    fi

    # Install missing tools
    print_section "Installing Missing Tools"

    # Install Homebrew first if on macOS
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi

    # Install each missing tool
    for tool in "${MISSING_TOOLS[@]}"; do
        case "$tool" in
            "Git")
                install_tool "Git" "git" "git" "git"
                ;;
            "Python 3.11+")
                if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
                    install_tool "Python 3.11" "python@3.11" "python3.11" "python3.11"
                else
                    echo -e "${YELLOW}Please install Python 3.11+ from python.org or your package manager${NC}"
                fi
                ;;
            "uv (Python package installer)")
                install_tool "uv" "" "" "" "install_uv"
                ;;
            "Copier (Template engine)")
                install_tool "Copier" "" "" "" "install_copier"
                ;;
            "VS Code (code CLI)")
                install_tool "VS Code" "" "" "" "install_vscode"
                ;;
            "PostgreSQL")
                if [[ "$OS" == "macos" ]]; then
                    install_tool "PostgreSQL (Postgres.app)" "" "" "" "install_postgres_app"
                else
                    install_tool "PostgreSQL" "" "postgresql postgresql-contrib" "postgresql-server"
                    echo -e "${YELLOW}Enable and start PostgreSQL:${NC}"
                    echo "  sudo systemctl enable postgresql"
                    echo "  sudo systemctl start postgresql"
                fi
                ;;
            "Ruff (Linter)")
                install_tool "Ruff" "" "" "" "install_ruff"
                ;;
            "Docker")
                if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
                    echo -e "${YELLOW}Installing Docker Desktop via Homebrew Cask...${NC}"
                    brew install --cask docker
                else
                    echo -e "${YELLOW}Please install Docker from docker.com${NC}"
                    echo "  https://docs.docker.com/engine/install/"
                fi
                ;;
            "Flyctl (Fly.io CLI)")
                install_tool "Flyctl" "" "" "" "install_flyctl"
                ;;
            "llm (AI CLI for changelogs)")
                install_tool "llm" "" "" "" "install_llm"
                ;;
            "eza (modern ls)")
                install_tool "eza" "eza" "eza" "eza"
                ;;
            "trash (safe delete)")
                install_tool "trash" "trash" "trash-cli" "trash-cli"
                ;;
            "thefuck (command correction)")
                install_tool "thefuck" "thefuck" "thefuck" "thefuck"
                ;;
            "fzf (fuzzy finder)")
                install_tool "fzf" "fzf" "fzf" "fzf"
                ;;
            "fd (modern find)")
                install_tool "fd" "fd" "fd-find" "fd-find"
                ;;
            "bat (cat with syntax)")
                install_tool "bat" "bat" "bat" "bat"
                ;;
            "tree (directory tree)")
                install_tool "tree" "tree" "tree" "tree"
                ;;
            "pyenv (Python version manager)")
                install_tool "pyenv" "pyenv" "pyenv" "pyenv"
                ;;
        esac
    done

    print_section "Configuring Shell"

    # Append to_zshrc to user's shell config
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local to_zshrc_file="$script_dir/to_zshrc"
    local github_raw_url="https://raw.githubusercontent.com/bennoloeffler/py_template_flyio/main/to_zshrc"

    # Try to find to_zshrc locally first, otherwise download from GitHub
    if [[ ! -f "$to_zshrc_file" ]]; then
        echo -e "${YELLOW}to_zshrc not found locally, downloading from GitHub...${NC}"
        to_zshrc_file="/tmp/to_zshrc.$$"

        if curl -fsSL "$github_raw_url" -o "$to_zshrc_file"; then
            echo -e "${GREEN}✓ Downloaded to_zshrc from GitHub${NC}"
        else
            echo -e "${RED}✗ Failed to download to_zshrc from GitHub${NC}"
            echo -e "${YELLOW}Skipping shell configuration...${NC}"
            to_zshrc_file=""
        fi
    else
        echo -e "${GREEN}✓ Found to_zshrc locally${NC}"
    fi

    if [[ -n "$to_zshrc_file" && -f "$to_zshrc_file" ]]; then
        # Determine shell config file
        local shell_config=""
        if [[ "$OS" == "macos" ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ -f "$HOME/.bashrc" ]]; then
            shell_config="$HOME/.bashrc"
        else
            shell_config="$HOME/.bash_profile"
        fi

        # Check if already appended (look for marker comment)
        if grep -q "# py_template_flyio configuration" "$shell_config" 2>/dev/null; then
            echo -e "${GREEN}✓ Shell configuration already present in $shell_config${NC}"
        else
            echo -e "${YELLOW}Appending to_zshrc content to $shell_config...${NC}"
            echo "" >> "$shell_config"
            echo "# py_template_flyio configuration - added by setup-tools.sh" >> "$shell_config"
            echo "# $(date)" >> "$shell_config"
            cat "$to_zshrc_file" >> "$shell_config"
            echo -e "${GREEN}✓ Shell configuration added to $shell_config${NC}"
            echo -e "${BLUE}Note: Restart your shell or run: source $shell_config${NC}"
        fi

        # Clean up temporary file if it was downloaded
        if [[ "$to_zshrc_file" == /tmp/to_zshrc.* ]]; then
            rm -f "$to_zshrc_file"
        fi
    fi

    print_section "Installation Complete"
    echo -e "${GREEN}✓ Setup finished!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal to ensure PATH is updated"
    if [[ "$OS" == "macos" ]]; then
        echo "  2. Open Postgres.app from Applications and initialize databases"
    else
        echo "  2. Configure PostgreSQL (create superuser if needed):"
        echo "     createuser -s postgres  # If user doesn't exist"
    fi
    echo "  3. Test template generation:"
    echo "     copier copy . /tmp/test_project"
    echo ""
    echo "Optional setup:"
    echo "  - Configure llm: llm keys set openai"
    echo "  - Login to Fly.io: flyctl auth login"
    if [[ "$OS" == "macos" ]]; then
        echo "  - Start Docker Desktop (if installed via Cask)"
    fi
}

# Run main function
main
