# ZSH-Terminal-Bootstrap

Standardising terminal for any new Terminal host.

* 🐚 Uses zsh as default shell
* 🔌 Oh-my-zsh for plugins (fast-syntax-highlighting & zsh-autosuggestions)
* 🎨 Oh-my-posh for themes
* 📚 Atuin for Shell history
* 🎨 iTerm 2 Profile switching (MacOS only)

## Notes
### Compatibility 🤖
- Supports macOS (Apple Silicon & Intel) and Linux (x86/AMD64 & ARM64)
- Tested on Apple M1/M4 macOS and Ubuntu Server 24.04 on x86/AMD64 & ARM64

### Pre-requisites ✅
- Install `Meslo Nerd Font` on your local host to render icons and glyphs correctly. Not required for remote hosts.
- Steps below assume a local `Atuin` server is available. If you don't have one, remove or skip the Atuin steps.

### Long-term goals 🎯
- [x] Streamline it. Reduce the steps & commands.
- [x] Speed up the `terminal` load times.

# Installation
## Script Install
1. Review the bootstrap script for your platform before running:
   * **Ubuntu** `https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh`
   * **macOS** `https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_macos.sh`
2. Run the installer for your platform:
   * **Ubuntu** `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh | bash`
   * **macOS** `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_macos.sh | bash`

## Updates to .zshrc
To pull the latest `.zshrc` and reload: `curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/.zshrc && exec zsh`

<img width="387" height="502" alt="image" src="https://github.com/user-attachments/assets/1cd1ba33-9c91-43b9-9b2d-3fe78d1e4f79" />

