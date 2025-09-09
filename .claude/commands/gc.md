---
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged changes only): !`git diff --cached`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Do not stage any additional files (ignore anything unstaged)
- There is a git commit hook that will run the `alejandra` nix formatter; if this fails, the git commit will not succeed; add any modified files and try re-running the commit

## Your task

Based on the above changes, check to make sure that documentation is up-to-date and then create a single git commit.

- Primarily adhere to the changes that are actually present in this commit -- don't overly reference changes that have happened in other commits already
- Additional notes (if any): $ARGUMENTS
