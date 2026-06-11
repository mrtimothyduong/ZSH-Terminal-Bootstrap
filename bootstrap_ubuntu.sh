#!/bin/bash
# bootstrap-ubuntu.sh

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

print_section "Starting Ubuntu Bootstrap Process"

# ─── Step 1: Update packages ───────────────────────────────────────────
print_section "Step 1: Updating Ubuntu Packages"
sudo apt-get update
sudo apt-get upgrade -y
print_status "Ubuntu packages updated!"

# ─── Step 2: Install essentials ───────────────────────────────────────
print_section "Step 2: Installing Essential Packages"
sudo apt install -y curl git zip zsh
print_status "Essential packages installed!"

# ─── Step 3: Oh-My-Zsh ────────────────────────────────────────────────
print_section "Step 3: Installing Oh-My-Zsh"
OMZ_HEALTHY=false
if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] \
    && [[ -f "$HOME/.oh-my-zsh/lib/compfix.zsh" ]] \
    && [[ -f "$HOME/.oh-my-zsh/tools/check_for_upgrade.sh" ]] \
    && [[ -d "$HOME/.oh-my-zsh/plugins/git" ]]; then
    OMZ_HEALTHY=true
fi

if [[ "$OMZ_HEALTHY" == false ]]; then
    # Remove any incomplete/partial install before retrying
    [[ -d "$HOME/.oh-my-zsh" ]] && rm -rf "$HOME/.oh-my-zsh"
    print_status "Installing Oh-My-Zsh..."
    RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_status "Oh-My-Zsh installed!"
else
    print_warning "Oh-My-Zsh already installed, skipping..."
fi

# ─── Step 4: ZSH plugins ──────────────────────────────────────────────
print_section "Step 4: Installing ZSH Plugins"
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

# ─── Step 5: Atuin ────────────────────────────────────────────────────
print_section "Step 5: Installing Atuin"
if ! command -v atuin &>/dev/null && [[ ! -f "$HOME/.atuin/bin/atuin" ]]; then
    print_status "Installing Atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    print_status "Atuin installed!"
else
    print_warning "Atuin already installed, skipping..."
fi

ATUIN_CONFIG="$HOME/.config/atuin/config.toml"
if [[ ! -f "$ATUIN_CONFIG" ]]; then
    mkdir -p "$(dirname "$ATUIN_CONFIG")"
    echo 'sync_address = "https://atuin.timothyduong.me"' > "$ATUIN_CONFIG"
    print_status "Atuin config created."
else
    print_warning "Atuin config already exists, skipping..."
fi

# ─── Step 6: Oh-My-Posh ───────────────────────────────────────────────
print_section "Step 6: Installing Oh-My-Posh"
if ! command -v oh-my-posh &>/dev/null; then
    print_status "Installing Oh-My-Posh to ~/.local/bin..."
    mkdir -p ~/.local/bin
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
    print_status "Oh-My-Posh installed!"
else
    print_warning "Oh-My-Posh already installed, skipping..."
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
ZSH_PATH="$(which zsh)"
print_status "Current shell: $SHELL"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    print_status "Changing default shell to $ZSH_PATH..."
    chsh -s "$ZSH_PATH"
    print_status "Default shell set to $ZSH_PATH"
else
    print_warning "ZSH ($ZSH_PATH) is already the default shell"
fi

# ─── Step 10: Summary ─────────────────────────────────────────────────
print_section "Bootstrap Complete!"
echo -e "${GREEN}Successfully installed:${NC}"
echo "  ✓ ZSH and essential packages"
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
echo -n "  Oh-My-Zsh:   "; [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] && echo "✓" || echo "✗"
echo -n "  Atuin:       "; command -v atuin       &>/dev/null && echo "✓" || echo "✗"
echo -n "  Oh-My-Posh:  "; command -v oh-my-posh  &>/dev/null && echo "✓" || echo "✗"
echo -n "  Theme:       "; [[ -f "$HOME/.quick-term.omp.json" ]] && echo "✓" || echo "✗"

print_section "Done!"
