#!/usr/bin/env python3
"""
Skill Packager - Creates a distributable zip file of a skill folder

Usage:
    python utils/package_skill.py <path/to/skill-folder> [output-directory]

Example:
    python utils/package_skill.py skills/public/my-skill
    python utils/package_skill.py skills/public/my-skill ./dist
"""

import sys
import zipfile
from collections.abc import Sequence
from pathlib import Path

from .quick_validate import validate_skill


def package_skill(
    skill_path: str | Path, output_dir: str | Path | None = None
) -> Path | None:
    """Package a skill folder into a zip file."""
    resolved_skill_path = Path(skill_path).resolve()

    # Validate skill folder exists
    if not resolved_skill_path.exists():
        print(f"❌ Error: Skill folder not found: {resolved_skill_path}")
        return None

    if not resolved_skill_path.is_dir():
        print(f"❌ Error: Path is not a directory: {resolved_skill_path}")
        return None

    # Validate SKILL.md exists
    skill_md = resolved_skill_path / "SKILL.md"
    if not skill_md.exists():
        print(f"❌ Error: SKILL.md not found in {resolved_skill_path}")
        return None

    # Run validation before packaging
    print("🔍 Validating skill...")
    valid, message = validate_skill(resolved_skill_path)
    if not valid:
        print(f"❌ Validation failed: {message}")
        print("   Please fix the validation errors before packaging.")
        return None
    print(f"✅ {message}\n")

    # Determine output location
    skill_name = resolved_skill_path.name
    if output_dir is not None:
        output_path = Path(output_dir).resolve()
        output_path.mkdir(parents=True, exist_ok=True)
    else:
        output_path = Path.cwd()

    zip_filename = output_path / f"{skill_name}.zip"

    # Create the zip file
    try:
        with zipfile.ZipFile(zip_filename, "w", zipfile.ZIP_DEFLATED) as zipf:
            # Walk through the skill directory
            for file_path in resolved_skill_path.rglob("*"):
                if file_path.is_file():
                    # Calculate the relative path within the zip
                    arcname = file_path.relative_to(resolved_skill_path.parent)
                    zipf.write(file_path, arcname)
                    print(f"  Added: {arcname}")

        print(f"\n✅ Successfully packaged skill to: {zip_filename}")
        return zip_filename

    except Exception as exc:  # pragma: no cover - print-only error path
        print(f"❌ Error creating zip file: {exc}")
        return None


def main(argv: Sequence[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)

    if not args:
        print(
            "Usage: python utils/package_skill.py <path/to/skill-folder> [output-directory]"
        )
        print("\nExample:")
        print("  python utils/package_skill.py skills/public/my-skill")
        print("  python utils/package_skill.py skills/public/my-skill ./dist")
        return 1

    skill_path = args[0]
    output_dir = args[1] if len(args) > 1 else None

    print(f"📦 Packaging skill: {skill_path}")
    if output_dir is not None:
        print(f"   Output directory: {output_dir}")
    print()

    result = package_skill(skill_path, output_dir)

    return 0 if result is not None else 1


if __name__ == "__main__":
    raise SystemExit(main())
