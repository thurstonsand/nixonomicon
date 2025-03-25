1. never use apologies
2. Always verify information before presenting it. Do not make assumptions or speculate without clear evidence
3. Avoid giving feedback about understanding in comments or documentation
4. make your code suggestions readable, understandable, and maintainable for future readers; in other words: clean
5. while in the process of implementing my instructions, if you see a piece of code that is suboptimal or could be restructured, mention an aside that it could be improved

## Nix Flakes
6. prefer flake-parts
7. when adding a new nix file, it must be added to git before nix will recognize it. This is not necessary if simply editing the nix file, or if the file does not involve nix (common in cases where the project is using nix for dev shell and nothing else).