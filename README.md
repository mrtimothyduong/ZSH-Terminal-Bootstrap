# ZSH-Terminal-Bootstrap

Standardising terminal for any new Terminal host.

<img width="555" alt="image" src="https://github.com/user-attachments/assets/12dd4986-9925-4a76-9488-0e48c90223ed" />

* 🐚 Uses zsh as default shell
* 🔌 Oh-my-zsh for plugins
* 🎨 Oh-my-posh for themes
* 📚 Atuin for Shell history

## Notes
### Compatibility 🤖
- Made for MacOS & AMD64 Linux Hosts. Atuin & Oh-My-Posh should now support ARM64
- Tested on Apple M1/M4 MacOS ARM devices & Ubuntu Server 24.04 on x86/AMD64 & ARM64

### Pre-requisites ✅
- Install `Menslo Nerd Fonts` to your local host to render icons / fonts. Not required for remote hosts.
- Steps below rely on a Local `Atuin` Server installed. If you do not have `atuin` installed.

### Long-term goals 🎯
- Streamline it. Reduce the steps & commands.
- Speed up the `terminal` load times.

# Installation
## Script Install
1. Review the contents of `https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh` before you run #2
2. Run the installer for the system required:
    **Ubuntu** Run `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_ubuntu.sh | bash`
    **MacOS** Run `sudo -v && curl -fsSL https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/bootstrap_macos.sh | bash`
3. Run `curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/mrtimothyduong/ZSH-Terminal-Bootstrap/refs/heads/main/.zshrc && exec zsh` to pull the latest .zshrc file

<img width="494" height="383" alt="image" src="https://github.com/user-attachments/assets/85637e79-b464-4a24-8ce7-748605b0430c" />