# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix flake-based configuration repository that manages system configurations across multiple platforms:
- macOS systems via nix-darwin
- NixOS systems
- User environments via home-manager
- Docker Compose stacks for containerized services
- Terraform for cloud infrastructure (Cloudflare)

## Essential Commands

### Apply Configuration Changes
```bash
switch
```
This alias runs `sudo darwin-rebuild switch --flake /Users/thurstonsand/Develop/nixonomicon` on macOS.

### Development Environment
```bash
nix develop
```
Enters a development shell with pre-commit hooks and formatting tools.

### Format Nix Code
```bash
nix fmt
```
Uses alejandra formatter. Pre-commit hooks run this automatically.

## Architecture Overview

### Directory Structure
- `/flake.nix` - Main entry point defining all system configurations
- `/common/` - Shared configurations across all systems
- `/darwin/` - macOS-specific configurations
  - `/darwin/system/` - System-level settings (packages, homebrew, etc.)
  - `/darwin/home.nix` - User environment for macOS
- `/nas/` - NixOS server configurations
  - `/nas/containers/` - Container service definitions (deprecated)
  - `/nas/stacks/` - Docker Compose stacks
- `/terraform/` - Infrastructure as Code (Cloudflare)

### Key Architectural Patterns

1. **Modular Configuration**: Each system (darwin, nas, steamdeck, truenas-shell) has its own module with shared common configurations.

2. **Flake Inputs**: Dependencies are managed through flake inputs, including:
   - nixpkgs (unstable channel)
   - home-manager
   - nix-darwin
   - Various community flakes

3. **Secret Management**: Uses git-crypt for secrets and 1Password integration for SSH keys and git signing.

4. **Service Architecture**: The NAS system runs services as Docker containers managed by NixOS, including Home Assistant, various Arr apps, and media servers.

## Development Guidelines

When working in this repository:
1. Be an expert in Nix, nix-darwin, home-manager, and Terraform
2. Use latest stable versions and techniques
3. Git stage changes before running `switch` - new/moved files must be staged or Nix won't see them
4. Test configuration changes with `switch` before committing
5. Let pre-commit hooks handle formatting
6. When creating Nix modules, minimize imports - if only `pkgs` is used, import only that
7. When targeting something in nix (e.g., `nix run ".#target"`), use quotes around the target name

## Important Context

- Primary user: `thurstonsand`
- Editor setup: Cursor/VS Code with Nix language support
- Shell: Zsh with extensive customizations
- Git: Integrated with 1Password for SSH signing
- Systems: Supports both aarch64-darwin (Apple Silicon) and x86_64-linux