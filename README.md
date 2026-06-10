# ZSH-Terminal-Bootstrap

Standardising terminal for any new Terminal host.

<img width="555" alt="image" src="https://github.com/user-attachments/assets/12dd4986-9925-4a76-9488-0e48c90223ed" />

* 🐚 Uses zsh as default shell
* 🔌 Oh-my-zsh for plugins
* 🎨 Oh-my-posh for themes
* 📚 Atuin for Shell history

## Notes
### Compatibility 🤖
- Supports macOS (Apple Silicon & Intel) and Linux (x86/AMD64 & ARM64)
- Tested on Apple M1/M4 macOS and Ubuntu Server 24.04 on x86/AMD64 & ARM64

### Pre-requisites ✅
- Install `Meslo Nerd Font` on your local host to render icons and glyphs correctly. Not required for remote hosts.
- Steps below assume a local `Atuin` server is available. If you don't have one, remove or skip the Atuin steps.

### Long-term goals 🎯
- Streamline it. Reduce the steps & commands.
- Speed up the `terminal` load times.

# Installation
## Script Install
1. Review the bootstrap script for your platform before running:
   * **Ubuntu** `https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh`
   * **macOS** `https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_macos.sh`
2. Run the installer for your platform:
   * **Ubuntu** `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh | bash`
   * **macOS** `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_macos.sh | bash`
3. Pull the latest `.zshrc` and reload: `curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/.zshrc && exec zsh`

<img width="494" height="383" alt="image" src="https://github.com/user-attachments/assets/85637e79-b464-4a24-8ce7-748605b0430c" />
