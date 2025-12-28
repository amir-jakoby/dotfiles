# Modern CLI Tools - TLDR

Quick reference for the 2025 shell tools.

## zoxide — Smart cd

```bash
z foo         # cd to directory matching "foo"
z foo bar     # cd to directory matching both
zi foo        # interactive selection (fzf)
z -           # go back to previous directory
```

**Tip:** Just use `z` instead of `cd`. It learns your habits.

---

## atuin — Shell History

```bash
Ctrl+R        # fuzzy search history (replaces default)
atuin search docker   # search for "docker" commands
atuin stats   # show history statistics
atuin sync    # sync across machines (needs login)
```

**First time:** Run `atuin login` or `atuin register` for cross-machine sync.

---

## eza — Modern ls

```bash
l             # basic list
ll            # long list with git status
la            # include hidden files
lt            # tree view (2 levels)
lta           # tree with hidden files
```

---

## delta — Git Diffs

No commands needed — automatically used for `git diff`, `git show`, `git log -p`.

```bash
delta file1 file2   # diff any two files
```

**Features:** syntax highlighting, line numbers, word-level diffs.

---

## mise — Version Manager

```bash
mise install node@20    # install Node.js 20
mise use node@20        # use in current project (.mise.toml)
mise global node@20     # set global default
mise ls                 # list installed versions
mise ls-remote python   # list available versions
mise x node@20 -- npm   # run command with specific version
```

**Replaces:** nvm, pyenv, rbenv, asdf — one tool for all languages.

---

## lazygit — Git TUI

```bash
lg            # open lazygit
```

**Navigation:**
- `hjkl` or arrows — move around
- `Space` — stage/unstage file
- `c` — commit
- `p` — push
- `P` — pull
- `?` — help

---

## yazi — File Manager

```bash
y             # open yazi (cd to dir on exit)
```

**Navigation:**
- `hjkl` or arrows — navigate
- `Enter` — open file/dir
- `q` — quit
- `y` — copy
- `p` — paste
- `d` — delete
- `/` — search
- `Space` — select multiple

---

## Quick Reference

| Task | Command |
|------|---------|
| Smart cd | `z dirname` |
| Search history | `Ctrl+R` |
| List files | `ll` |
| Git diff | `git diff` (delta auto) |
| Install Node 20 | `mise install node@20` |
| Git UI | `lg` |
| File manager | `y` |
