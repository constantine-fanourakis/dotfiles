---
name: dotfiles
description: Manage the bare dotfiles repo (git dir ~/.dotfiles, work tree ~). USE WHEN the user asks to check, pull, sync, commit, push, or add files to their dotfiles/config repo (zshrc, nvim, lazygit, tmux, gitconfig, etc.). Overrides the commit-message skill for this repo.
---

# Dotfiles repo

Every git command uses the bare-repo invocation:

    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME

Below, `dotfiles` stands for that full invocation (it is also an interactive
zsh alias, but aliases are unavailable in tool calls — always spell it out).

Remote: `github.com:constantine-fanourakis/dotfiles.git`, branch `master`.
Commits are SSH-signed via 1Password; no extra flags needed, but signing may
trigger an approval prompt.

This skill's canonical file is `~/.config/claude/skills/dotfiles/SKILL.md`,
tracked in the dotfiles repo. `~/.claude/skills/dotfiles` is a symlink to
that directory: `~/.claude` is a separate local-only git repo, and the
dotfiles repo cannot track paths inside a nested repo. On a new machine,
recreate the link:

    ln -s $HOME/.config/claude/skills/dotfiles $HOME/.claude/skills/dotfiles

## Hard rules

- The work tree is `$HOME`. Never run `add .`, `add -A`, `stash -u`, or
  `clean` — always name files explicitly.
- Commit subjects are plain capitalized imperative ("Add fnm env init to
  zshrc"). Conventional Commits and the commit-message skill do NOT apply
  here. Body only when the change needs explanation; never any trailers.
- One logical change per commit. When unrelated files are modified, commit
  each separately with a pathspec: `dotfiles commit -m "..." -- <path>`.
- `status.showUntrackedFiles` is `no`, so status only reports tracked files.
  Use `dotfiles status -u <dir>` to see untracked files under a directory.

## Workflows

**Check state**

    dotfiles fetch
    dotfiles status --short --branch
    dotfiles log --oneline master..origin/master

**Pull with local modifications**

1. `dotfiles stash push -m "pre-pull"` (tracked files only)
2. `dotfiles merge --ff-only origin/master`
3. `dotfiles stash pop` — on conflict, resolve, `dotfiles add <file>`, then
   `dotfiles stash drop` (pop keeps the entry when conflicts occur)
4. Run `zsh -n ~/.zshrc` after any merge touching `.zshrc`

**Push**

Pushing after committing is the normal flow, but when the user asked only to
commit, leave the push to them.

**Track a new config file**

Never track a file that tools rewrite in place (e.g. `~/.gitconfig`, which
`git config --global` targets). Track a shared file that the untracked
machine-local file includes or sources — e.g. tracked `~/.gitconfig.global`
is pulled in by each machine's `~/.gitconfig` via an `[include]` block placed
first, so machine-local values win under last-value-wins. The same pattern
applies to shell rc files.

## File conventions

- `.zshrc` is OS-aware and fail-soft: macOS-specific setup (Homebrew,
  1Password SSH agent, conda, Docker completions, fnm) lives inside the
  `IS_MACOS` block; cross-platform tool init is guarded by `command -v` with
  an `_zshrc_warn` fallback instead of failing. Match both patterns when
  adding entries, and run `zsh -n ~/.zshrc` after edits.
