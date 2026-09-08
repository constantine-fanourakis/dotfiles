---
name: setup-project
description: Configure a new or existing repository with the standard CLAUDE.md (from the personal template) and a project-customized Conventional Commits skill. USE WHEN the user asks to set up, configure, initialize, or bootstrap a project's Claude config.
---

# Setup Project

Configure the current repository with two things:

1. A `CLAUDE.md` based on the personal template.
2. A project-scoped `commit-message` skill whose scopes are tailored to this repo.

Propose drafts and get confirmation before writing files. Never overwrite an existing file without asking.

## 1. Locate the project root

Run `git rev-parse --show-toplevel` to find the root. If this is not a git repository, use the current directory and note that commit-scope detection from history will be skipped.

## 2. Install CLAUDE.md

Template source: `~/Documents/notes/claude/project_CLAUDE_template.md`. If the template is missing, tell the user and instead create a minimal `CLAUDE.md` containing `## Project`, `## Architecture`, and `## Conventions` sections plus the template's Coding Guidelines and Code Comments standards.

**If `<root>/CLAUDE.md` does not exist:**
- Copy the template to `<root>/CLAUDE.md`.
- Inspect the repo and fill in the placeholder sections, then show the draft and confirm before writing:
  - `## Project` — Build / Test / Run commands. Detect from `Makefile`, `CMakeLists.txt`, `package.json` scripts, `pyproject.toml` / `setup.py` / `tox.ini`, `Cargo.toml`, etc.
  - `## Architecture` — a short 2-5 bullet summary of the main components and directories.
  - `## Conventions` — keep `Commits: Conventional Commits`; add any formatter/linter conventions you detect (e.g. `.clang-format`, `ruff`, `prettier`).

**If `<root>/CLAUDE.md` already exists:**
- Do not overwrite. Compare it against the template, list the sections it lacks (e.g. Coding Guidelines, Code Comments), and propose appending only those. Confirm before editing.

## 3. Generate the project commit skill

Target path: `<root>/.claude/skills/commit-message/SKILL.md` (committed to the repo so teammates share the conventions). If it already exists, ask before overwriting.

Base it on the user-level skill at `~/.claude/skills/commit-message/SKILL.md` — reproduce its Conventional Commits format, allowed type list, subject rules, the "show the message and ask before committing" step, and the no-trailers rule. The project skill must be self-contained, since a project skill named `commit-message` shadows the global one within this repo.

Customize the **scopes** for this repo:
- Derive candidate scopes from the top-level source directories and from existing `type(scope):` subjects in history: `git log --pretty=%s -n 300`, then tally the scopes that recur.
- If there is no git history, derive scopes from the directory structure only.
- Present the proposed scope list and let the user edit and confirm it before writing.

Ask whether the project uses a ticket-reference convention (e.g. `FW-123`); if so, document in the skill where it belongs (subject or footer).

Set the generated file's frontmatter `name` to `commit-message` so it overrides the global skill inside this repo.

## 4. Finish

State the paths of the files created or modified, and note that `CLAUDE.md` and `.claude/skills/commit-message/SKILL.md` should be committed to share them with the team. Do not run the commit yourself.
