#!/usr/bin/env python3
"""
Quick validation script for skills - minimal version
"""

import re
import sys
from collections.abc import Sequence
from pathlib import Path


def validate_skill(skill_path: str | Path) -> tuple[bool, str]:
    """Basic validation of a skill."""
    skill_path = Path(skill_path)

    # Check SKILL.md exists
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return False, "SKILL.md not found"

    # Read and validate frontmatter
    content = skill_md.read_text()
    if not content.startswith("---"):
        return False, "No YAML frontmatter found"

    # Extract frontmatter
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter = match.group(1)

    # Check required fields
    if "name:" not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if "description:" not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    # Extract name for validation
    name_match = re.search(r"name:\s*(.+)", frontmatter)
    if name_match:
        name = name_match.group(1).strip()
        # Check naming convention (hyphen-case: lowercase with hyphens)
        if not re.match(r"^[a-z0-9-]+$", name):
            return (
                False,
                "Name '{name}' should be hyphen-case (lowercase letters, digits, and hyphens only)".format(
                    name=name
                ),
            )
        if name.startswith("-") or name.endswith("-") or "--" in name:
            return (
                False,
                "Name '{name}' cannot start/end with hyphen or contain consecutive hyphens".format(
                    name=name
                ),
            )

    # Extract and validate description
    desc_match = re.search(r"description:\s*(.+)", frontmatter)
    if desc_match:
        description = desc_match.group(1).strip()
        # Check for angle brackets
        if "<" in description or ">" in description:
            return False, "Description cannot contain angle brackets (< or >)"

    return True, "Skill is valid!"


def main(argv: Sequence[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)

    if len(args) != 1:
        print("Usage: python quick_validate.py <skill_directory>")
        return 1

    valid, message = validate_skill(args[0])
    print(message)
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
