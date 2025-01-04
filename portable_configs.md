# NixOS Configuration File Locations

This document lists the important configuration file locations in the NixOS build output that might be useful for replicating configurations on non-NixOS systems.

## Shell Environment

- `/etc/zshrc` - System-wide Zsh configuration
- `/etc/zshenv` - System-wide Zsh environment variables
- `/etc/zprofile` - System-wide Zsh profile
- `/etc/bashrc` - System-wide Bash configuration
- `/etc/profile` - System-wide shell profile
- `/etc/inputrc` - Readline configuration (affects all shells)

## Development Tools

### Editors
- `/sw/share/nvim/` - Neovim configuration and plugins
- `/sw/share/vim-plugins/` - Vim plugins

### Version Control
- `/sw/share/git/` - Git configuration and templates
- `/sw/share/git-core/` - Git core files
- `/sw/share/git-gui/` - Git GUI configuration
- `/sw/share/gitk/` - Gitk configuration

### Terminal
- `/sw/share/ghostty/` - Ghostty terminal configuration
- `/sw/share/terminfo/` - Terminal definitions

### Shell Tools
- `/sw/share/bat/` - Bat (cat replacement) configuration
- `/sw/share/fish/` - Fish shell configuration and completions

## Desktop Environment

### X11 and Display
- `/etc/X11/` - X11 configuration files
- `/sw/share/X11/` - X11 resources and applications

### Theming and Appearance
- `/sw/share/gtk-3.0/` - GTK3 configuration and settings
- `/sw/share/themes/` - System-wide themes
- `/sw/share/icons/` - Icon themes
- `/sw/share/fonts/` - System fonts

### System Services
- `/etc/systemd/` - Systemd service configurations
- `/etc/dbus-1/` - D-Bus configuration
- `/etc/NetworkManager/` - Network configuration

## Notes

1. These paths are relative to the build output directory
2. Some configurations might need adaptation for non-NixOS systems
3. User-specific configurations might need to be placed in different locations depending on the target system
4. Some configurations might contain Nix-specific paths that need to be adjusted

---

# Portable Configuration Extraction

## Overview
We've set up a GitHub Actions workflow that automatically extracts portable configuration files from the NixOS configuration and stores them in `nas/home/`. These portable configs can be used in non-NixOS environments without requiring Nix.

## Current Implementation
- Location: `.github/workflows/nixos-build.yaml`
- Target Directory: `nas/home/`
- Current Configs:
  - Git configuration (`nas/home/git/`)
    - `config`: Global git configuration (with Nix-specific paths removed)
    - `ignore`: Global git ignore patterns

## How It Works
1. The workflow runs on changes to:
   - `nas/system/**`
   - `common/**`
   - `flake.nix`
   - `flake.lock`
   - `.github/workflows/nixos-build.yaml`

2. During PRs:
   - Shows potential changes to portable configs
   - Does not create a PR for the changes

3. After merge to main:
   - Extracts updated configs
   - Creates a PR if there are changes
   - PR uses branch name `update-portable-configs`

## Extracting Configs
To extract a config from the NixOS build, use this command pattern:
```bash
nix eval --raw '.#nixosConfigurations.knownapps.config.home-manager.users.thurstonsand.home.file."$PATH".text'
```

Example for git config:
```bash
nix eval --raw '.#nixosConfigurations.knownapps.config.home-manager.users.thurstonsand.home.file."/home/thurstonsand/.config/git/config".text'
```

To list all available files in home-manager:
```bash
nix eval --json '.#nixosConfigurations.knownapps.config.home-manager.users.thurstonsand.home.file' | jq 'keys[]'
```

## Adding New Configs
When adding new configs:
1. Identify the home-manager path of the config file
2. Check if it contains any Nix-specific paths or references that need to be removed
3. Add the extraction command to the workflow's "Extract portable configs" step
4. Create the appropriate directory structure in `nas/home/`

## Important Considerations
1. Always check extracted configs for Nix store paths (`/nix/store/`)
2. Consider if system-specific paths need to be adjusted
3. Some configs might need additional processing (like removing specific lines)
4. Target systems will need to have required programs installed

## Required Information for Future Changes
When requesting to add new portable configs, please provide:
1. The home-manager path of the config file
2. Whether it contains any Nix-specific paths or references
3. Any system-specific paths that might need adjustment
4. Required programs or dependencies for the config to work
