#!/bin/bash
# bootstrap-macos.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${GREEN}[INFO]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_section() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===================================================${NC}\n"
}

trap 'print_error "Script failed at line $LINENO"' ERR

# Detect Homebrew prefix (Apple Silicon vs Intel)
if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

print_section "Starting macOS Bootstrap Process"

# ─── Step 1: Xcode Command Line Tools ─────────────────────────────────
print_section "Step 1: Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    print_status "Installing Xcode Command Line Tools..."
    print_warning "A dialog will appear — click Install, then re-run this script."
    xcode-select --install
    exit 0
else
    print_warning "Xcode CLT already installed, skipping..."
fi

# ─── Step 2: Homebrew ──────────────────────────────────────────────────
print_section "Step 2: Homebrew"
if ! command -v brew &>/dev/null; then
    print_status "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    print_status "Homebrew installed!"
else
    print_warning "Homebrew already installed, updating..."
    brew update
fi

# ─── Step 3: Core packages ─────────────────────────────────────────────
print_section "Step 3: Installing Packages via Homebrew"
brew install git curl zsh
brew install atuin
brew install jandedobbeleer/oh-my-posh/oh-my-posh
print_status "Packages installed!"

# ─── Step 4: Oh-My-Zsh ────────────────────────────────────────────────
print_section "Step 4: Installing Oh-My-Zsh"
if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    # Remove any incomplete/partial install before retrying
    [[ -d "$HOME/.oh-my-zsh" ]] && rm -rf "$HOME/.oh-my-zsh"
    print_status "Installing Oh-My-Zsh..."
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_status "Oh-My-Zsh installed!"
else
    print_warning "Oh-My-Zsh already installed, skipping..."
fi

# ─── Step 5: ZSH plugins ──────────────────────────────────────────────
print_section "Step 5: Installing ZSH Plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    print_status "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_status "zsh-autosuggestions installed!"
else
    print_warning "zsh-autosuggestions already installed, skipping..."
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]]; then
    print_status "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    print_status "fast-syntax-highlighting installed!"
else
    print_warning "fast-syntax-highlighting already installed, skipping..."
fi

# ─── Step 6: Atuin config ─────────────────────────────────────────────
print_section "Step 6: Configuring Atuin"
ATUIN_CONFIG="$HOME/.config/atuin/config.toml"
if [[ ! -f "$ATUIN_CONFIG" ]]; then
    mkdir -p "$(dirname "$ATUIN_CONFIG")"
    echo 'sync_address = "https://atuin.timothyduong.me"' > "$ATUIN_CONFIG"
    print_status "Atuin config created."
else
    print_warning "Atuin config already exists, skipping..."
fi

# ─── Step 7: Oh-My-Posh theme ─────────────────────────────────────────
print_section "Step 7: Downloading Oh-My-Posh Theme"
curl -fsSL -o ~/.quick-term.omp.json \
    https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/.quick-term.omp.json
print_status "Theme downloaded!"

# ─── Step 8: .zshrc ───────────────────────────────────────────────────
print_section "Step 8: Configuring .zshrc"
if [[ -f ~/.zshrc ]]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp ~/.zshrc "$BACKUP"
    print_status "Backup created: $BACKUP"
fi

print_status "Downloading .zshrc from GitHub..."
curl -fsSL -o ~/.zshrc \
    https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/.zshrc
print_status ".zshrc downloaded!"

# ─── Step 9: Default shell ─────────────────────────────────────────────
print_section "Step 9: Setting ZSH as Default Shell"
ZSH_PATH="$(brew --prefix)/bin/zsh"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    if ! grep -qF "$ZSH_PATH" /etc/shells; then
        print_status "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    chsh -s "$ZSH_PATH"
    print_status "Default shell set to $ZSH_PATH"
else
    print_warning "ZSH ($ZSH_PATH) is already the default shell"
fi

# ─── Step 10: Summary ─────────────────────────────────────────────────
print_section "Bootstrap Complete!"
echo -e "${GREEN}Successfully installed:${NC}"
echo "  ✓ Homebrew"
echo "  ✓ Git, curl, zsh"
echo "  ✓ Oh-My-Zsh + plugins"
echo "  ✓ Atuin"
echo "  ✓ Oh-My-Posh + quick-term theme"
echo ""
echo -e "${YELLOW}IMPORTANT — Manual Steps:${NC}"
echo -e "  1. Login to Atuin: ${BLUE}atuin login -u $(whoami)${NC}"
echo    "     (password in 1Password)"
echo -e "  2. Restart terminal or run: ${BLUE}exec zsh${NC}"
echo ""

print_status "Verifying installations..."
echo -n "  Homebrew:    "; command -v brew        &>/dev/null && echo "✓" || echo "✗"
echo -n "  Oh-My-Zsh:   "; [[ -d "$HOME/.oh-my-zsh" ]]      && echo "✓" || echo "✗"
echo -n "  Atuin:       "; command -v atuin       &>/dev/null && echo "✓" || echo "✗"
echo -n "  Oh-My-Posh:  "; command -v oh-my-posh  &>/dev/null && echo "✓" || echo "✗"
echo -n "  Theme:       "; [[ -f "$HOME/.quick-term.omp.json" ]] && echo "✓" || echo "✗"

print_section "Done!"
