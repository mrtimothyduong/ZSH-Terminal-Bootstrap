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

# Download to a temp file, then move into place, so a failed download
# never leaves a truncated file behind.
download() {
    local url="$1" dest="$2" tmp
    tmp="$(mktemp)"
    if ! curl -fsSL -o "$tmp" "$url"; then
        rm -f "$tmp"
        print_error "Download failed: $url"
        return 1
    fi
    mv "$tmp" "$dest"
}

# Atuin and Oh-My-Posh install into these directories. Put them on PATH
# now so the "already installed" checks and final verification find them.
export PATH="$HOME/.local/bin:$HOME/.atuin/bin:$PATH"

REPO_RAW="https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main"

print_section "Starting Ubuntu Bootstrap Process"

# ─── Step 1: Update packages ───────────────────────────────────────────
print_section "Step 1: Updating Ubuntu Packages"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
print_status "Ubuntu packages updated!"

# ─── Step 2: Install essentials ───────────────────────────────────────
print_section "Step 2: Installing Essential Packages"
# unzip is required by the Oh-My-Posh installer
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl git zip unzip zsh
print_status "Essential packages installed!"

# ─── Step 3: Oh-My-Zsh ────────────────────────────────────────────────
print_section "Step 3: Installing Oh-My-Zsh"
omz_healthy() {
    [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] \
        && [[ -f "$HOME/.oh-my-zsh/lib/compfix.zsh" ]] \
        && [[ -f "$HOME/.oh-my-zsh/tools/check_for_upgrade.sh" ]] \
        && [[ -d "$HOME/.oh-my-zsh/plugins/git" ]]
}

if ! omz_healthy; then
    # Move any incomplete/partial install aside rather than deleting it,
    # so anything in custom/ can be recovered.
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        OMZ_BAK="$HOME/.oh-my-zsh.broken.$(date +%Y%m%d_%H%M%S)"
        mv "$HOME/.oh-my-zsh" "$OMZ_BAK"
        print_warning "Moved broken install to $OMZ_BAK"
    fi
    print_status "Installing Oh-My-Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
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
if ! command -v atuin &>/dev/null; then
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
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
    print_status "Oh-My-Posh installed!"
else
    print_warning "Oh-My-Posh already installed, skipping..."
fi

# ─── Step 7: Oh-My-Posh theme ─────────────────────────────────────────
print_section "Step 7: Downloading Oh-My-Posh Theme"
download "$REPO_RAW/.quick-term.omp.json" "$HOME/.quick-term.omp.json"
print_status "Theme downloaded!"

# ─── Step 8: .zshrc ───────────────────────────────────────────────────
# Runs after the Atuin installer on purpose: that installer appends its
# own init lines to shell rc files, which this download replaces.
print_section "Step 8: Configuring .zshrc"
if [[ -f "$HOME/.zshrc" ]]; then
    BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP"
    print_status "Backup created: $BACKUP"
fi

print_status "Downloading .zshrc from GitHub..."
download "$REPO_RAW/.zshrc" "$HOME/.zshrc"
print_status ".zshrc downloaded!"

# ─── Step 9: Default shell ─────────────────────────────────────────────
print_section "Step 9: Setting ZSH as Default Shell"
ZSH_PATH="$(command -v zsh)"
# $SHELL only updates at next login, so read the account's real shell.
login_shell() { getent passwd "$USER" | cut -d: -f7; }
CURRENT_SHELL="$(login_shell)"
print_status "Current login shell: $CURRENT_SHELL"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    print_status "Changing default shell to $ZSH_PATH..."
    # sudo is already cached from Step 1, so this avoids a second password prompt
    sudo chsh -s "$ZSH_PATH" "$USER"
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
echo -e "  2. Log out and back in (or run ${BLUE}exec zsh${NC})"
echo ""

print_status "Verifying installations..."
check() { if "$@" &>/dev/null; then echo "✓"; else echo "✗"; fi; }
echo -n "  Oh-My-Zsh:   "; check omz_healthy
echo -n "  Plugins:     "; check test -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" -a -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
echo -n "  Atuin:       "; check command -v atuin
echo -n "  Oh-My-Posh:  "; check command -v oh-my-posh
echo -n "  Theme:       "; check test -f "$HOME/.quick-term.omp.json"
echo -n "  Shell:       "; check test "$(login_shell)" = "$ZSH_PATH"

print_section "Done!"
