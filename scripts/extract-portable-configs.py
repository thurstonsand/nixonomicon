#!/usr/bin/env python3
"""
Extract portable configurations from NixOS/home-manager build.
These configs work on non-NixOS systems without Nix.
"""

import json
import re
import subprocess
from pathlib import Path
from typing import cast

SCRIPT_DIR: Path = Path(__file__).parent.resolve()
REPO_ROOT: Path = SCRIPT_DIR.parent
HOME_DIR: Path = REPO_ROOT / "nas" / "stacks" / "sshd" / "home"

NIX_CONFIG: str = ".#nixosConfigurations.knownapps.config"
HM_USER: str = f"{NIX_CONFIG}.home-manager.users.thurstonsand"

# Type alias for JSON values - using object to avoid Any
type JsonValue = dict[str, object] | list[object] | str | int | float | bool | None


def nix_eval_json(expr: str) -> JsonValue:
    """Evaluate a nix expression and return parsed JSON."""
    result: subprocess.CompletedProcess[str] = subprocess.run(
        ["nix", "eval", "--json", expr],
        capture_output=True,
        text=True,
        cwd=REPO_ROOT,
        check=True,
    )
    return cast(JsonValue, json.loads(result.stdout))


def get_hm_file_text(path: str) -> str:
    """Get the text content of a home-manager managed file.

    Some files use 'text' directly, others use 'source' pointing to a nix store path.
    This function handles both cases.
    """
    data: JsonValue = nix_eval_json(f'{HM_USER}.home.file."{path}"')
    if not isinstance(data, dict):
        raise TypeError(f"Expected dict for {path}, got {type(data).__name__}")

    text: object = data.get("text")
    if isinstance(text, str):
        return text

    source: object = data.get("source")
    if isinstance(source, str):
        source_path = Path(source)
        if source_path.exists():
            return source_path.read_text()
        raise FileNotFoundError(
            f"Source file {source} for {path} not found (build NixOS config first)"
        )

    raise TypeError(
        f"Expected 'text' or 'source' in {path}, got text={type(text).__name__}, source={type(source).__name__}"
    )


def get_starship_config() -> str:
    """Get starship config, converting from settings if source file unavailable."""
    try:
        return get_hm_file_text("/home/thurstonsand/.config/starship.toml")
    except FileNotFoundError:
        pass

    settings: JsonValue = nix_eval_json(f"{HM_USER}.programs.starship.settings")
    if not isinstance(settings, dict):
        raise TypeError(
            f"Expected dict for starship settings, got {type(settings).__name__}"
        )

    return dict_to_toml(settings)


def dict_to_toml(obj: dict[str, object]) -> str:
    """Convert a dict to TOML format."""
    lines: list[str] = []
    subsections: list[tuple[str, dict[str, object]]] = []

    for key, value in obj.items():
        if isinstance(value, dict):
            subsections.append((key, cast(dict[str, object], value)))
        elif isinstance(value, bool):
            lines.append(f"{key} = {str(value).lower()}")
        elif isinstance(value, str):
            lines.append(f'{key} = "{value}"')
        elif isinstance(value, int | float):
            lines.append(f"{key} = {value}")

    for i, (section_name, section_dict) in enumerate(subsections):
        if i > 0 or lines:
            lines.append("")
        lines.append(f"[{section_name}]")
        for key, value in section_dict.items():
            if isinstance(value, bool):
                lines.append(f"{key} = {str(value).lower()}")
            elif isinstance(value, str):
                lines.append(f'{key} = "{value}"')
            elif isinstance(value, int | float):
                lines.append(f"{key} = {value}")

    return "\n".join(lines) + "\n"


def make_portable_git_config(text: str) -> str:
    """Transform git config to be portable (no nix store paths)."""
    # First pass: collect sections and their content
    sections: dict[str, list[str]] = {}
    current_section: str | None = None

    for line in text.splitlines():
        # Track sections
        if line.startswith("["):
            current_section = line
            if current_section not in sections:
                sections[current_section] = []
            continue

        if current_section is None:
            continue

        # Skip lines with nix store paths
        if "/nix/store/" in line:
            continue

        # Skip gpg program lines (1Password path is mac-specific)
        if "program = " in line:
            continue

        # Skip empty helper lines
        if 'helper = ""' in line:
            continue

        # Only keep non-empty lines as content
        if line.strip():
            sections[current_section].append(line)

    # Second pass: output only sections with content
    lines: list[str] = []
    for section, content in sections.items():
        if content:  # Only include sections that have content
            lines.append(section)
            lines.extend(content)
            lines.append("")

    # Clean up multiple blank lines
    result: str = "\n".join(lines)
    result = re.sub(r"\n{3,}", "\n\n", result)
    return result.strip() + "\n"


def make_portable_zshrc(text: str) -> str:
    """Transform zshrc to be portable (no nix store paths)."""
    lines: list[str] = []
    skip_nix_profiles_loop: bool = False

    for line in text.splitlines():
        # Skip NIX_PROFILES fpath loop
        if "NIX_PROFILES" in line and "for profile" in line:
            skip_nix_profiles_loop = True
            continue
        if skip_nix_profiles_loop:
            if line.strip() == "done":
                skip_nix_profiles_loop = False
            continue

        # Skip HELPDIR
        if line.startswith("HELPDIR="):
            continue

        # Skip switch alias (nix-specific)
        if line.startswith("alias -- switch="):
            continue

        # Transform zsh-autosuggestions source
        if re.match(r"^source /nix/store/.*/zsh-autosuggestions\.zsh$", line):
            lines.append("# Autosuggestions (install zsh-autosuggestions package)")
            lines.append(
                "[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && "
                + "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
            )
            continue

        # Transform zsh-syntax-highlighting source
        if re.match(r"^source /nix/store/.*/zsh-syntax-highlighting\.zsh$", line):
            lines.append(
                "# Syntax highlighting (install zsh-syntax-highlighting package)"
            )
            lines.append(
                "[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && "
                + "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
            )
            continue

        # Replace hardcoded home path with $HOME
        line = line.replace("/home/thurstonsand", "$HOME")

        lines.append(line)

    # Add header
    header: list[str] = [
        "# Portable zshrc - extracted from NixOS configuration",
        "# Works on any system with zsh and the required tools installed",
        "",
    ]

    result: str = "\n".join(header + lines)
    # Clean up multiple blank lines
    result = re.sub(r"\n{3,}", "\n\n", result)
    return result.strip() + "\n"


def make_portable_zprofile(text: str) -> str:
    """Transform zprofile to be portable."""
    # Just replace hardcoded home path
    return text.replace("/home/thurstonsand", "$HOME")


def main() -> None:
    print(f"Extracting portable configs to {HOME_DIR}...")

    # Create directory structure
    (HOME_DIR / ".config" / "git").mkdir(parents=True, exist_ok=True)

    # =========================================================================
    # Git Configuration
    # =========================================================================
    print("  Extracting git config...")
    git_config = get_hm_file_text("/home/thurstonsand/.config/git/config")
    portable_config = make_portable_git_config(git_config)
    _ = (HOME_DIR / ".config" / "git" / "config").write_text(portable_config)

    # =========================================================================
    # Git Ignore
    # =========================================================================
    print("  Extracting git ignore...")
    git_ignore = get_hm_file_text("/home/thurstonsand/.config/git/ignore")
    _ = (HOME_DIR / ".config" / "git" / "ignore").write_text(git_ignore)

    # =========================================================================
    # Zsh Configuration
    # =========================================================================
    print("  Extracting zsh config...")
    zshrc = get_hm_file_text("/home/thurstonsand/.zshrc")
    portable_zshrc = make_portable_zshrc(zshrc)
    _ = (HOME_DIR / ".zshrc").write_text(portable_zshrc)

    # =========================================================================
    # Zsh Profile (contains the _evalcache function)
    # =========================================================================
    print("  Extracting zsh profile...")
    zprofile = get_hm_file_text("/home/thurstonsand/.zprofile")
    portable_zprofile = make_portable_zprofile(zprofile)
    _ = (HOME_DIR / ".zprofile").write_text(portable_zprofile)

    # =========================================================================
    # Starship Configuration
    # =========================================================================
    print("  Extracting starship config...")
    starship_text = get_starship_config()
    _ = (HOME_DIR / ".config" / "starship.toml").write_text(starship_text)

    print("Done!")
    print()
    print("Extracted configs:")
    for f in sorted(HOME_DIR.rglob("*")):
        if f.is_file():
            print(f"  {f.relative_to(HOME_DIR)}")


if __name__ == "__main__":
    main()
