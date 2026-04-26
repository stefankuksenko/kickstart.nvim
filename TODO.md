# Neovim Config TODO

## Open

### 1. Reload notification — add diff counts

**Status:** Nice-to-have

**Goal:** Enhance the reload notification to show line counts like
`File reloaded from disk (+1 added, ~2 changed, -3 deleted)` instead of just
`File reloaded from disk`.

**Problem:** The mtime-based approach requires storing full buffer content to diff.
Previous attempts had inaccurate counts — likely because stored content got updated
between rapid consecutive edits, so the diff was computed against an intermediate state.

**Next steps:**
- Store buffer content alongside mtime (currently only mtime is tracked)

### 2. Enable friendly-snippets

**Status:** Deferred

**Goal:** Uncomment `rafamadriz/friendly-snippets` in init.lua for premade code snippets.

**Available snippets:** terraform, kubernetes, docker, java, python, typescript,
javascript, go. No helm/terragrunt/HCL-specific snippets.

**Why deferred:** Want to get comfortable with LSP autocompletion first before adding
more noise to the completion menu. Enable when ready.

### 3. AI inline completion (Copilot)

**Status:** Deferred

**Goal:** Add ghost text inline suggestions (like VSCode/JetBrains Tab completion).

**Plan:** Use `zbirenbaum/copilot.lua` with enterprise GitHub Copilot license.
Authenticate with `:Copilot auth`. Alternative: `supermaven-inc/supermaven-nvim`
(faster, free tier) if Copilot doesn't work out.

**Why deferred:** Get comfortable with base nvim + LSP first.

### 4. Set up linters per language

**Status:** Deferred — set up after LSP servers

**Goal:** Enable `kickstart.plugins.lint` and configure linters for the stack:
- Python: `ruff` or `pylint`
- TypeScript/JavaScript: `eslint`
- Terraform: `tflint`
- YAML/Helm: `yamllint`
- Bash: `shellcheck`
- Java: `checkstyle` (or rely on LSP)
- Go templates: (no standard linter)

**Why deferred:** LSP covers most diagnostics. Linters add style/best-practice
checks. Set up when starting real projects in each language.

### 5. Set up LSP servers for all languages

**Status:** Next priority

**Goal:** Add LSP servers to the `servers` table in init.lua:
- Python: `pyright`
- TypeScript: `ts_ls`
- Java: `jdtls`
- Terraform: `terraformls`
- YAML: `yamlls` (with Kubernetes schema)
- Go: `gopls`
- Bash: `bashls`

### 7. Helm template validation without saving

**Status:** Investigate

**Problem:** helm_ls only validates against CRD schemas on save, not as you type.
This is because helm_ls needs to render the template (`helm template`) before
passing the output to yamlls for validation. Rendering on every keystroke could
be slow and fail on incomplete edits.

**Next steps:**
- Check helm_ls config for a `triggerValidation` or `didChange` setting
- Check if newer helm_ls versions support incremental validation
- Consider auto-save on CursorHold as a workaround (`:update` only writes if changed)

### 8. Terragrunt LSP / tooling

**Status:** Research needed

**Goal:** IDE-like support for Terragrunt `.hcl` files:
- Resolve and render variables, locals, inputs
- Jump to `dependency` blocks / parent configs (`include` paths)
- Jump to the Terraform module source
- Autocomplete Terragrunt-specific blocks (`dependency`, `include`, `inputs`, etc.)
- Understand the directory hierarchy (parent/child config inheritance)

**Current state:** Only treesitter syntax highlighting for `.hcl` files. No LSP.

**Options to investigate:**
- `terragrunt-ls` — does it exist? Check if there's an official/community LSP
- `terraformls` on `.hcl` — might partially work for HCL syntax but won't
  understand Terragrunt-specific blocks
- Custom nvim plugin for Terragrunt navigation (e.g., `grd` on a `dependency`
  path to jump to that config)
- Generic HCL LSP options

### 9. GitHub Actions LSP

**Status:** Deferred

**Goal:** IDE support for `.github/workflows/*.yml` files — autocompletion for
action names, input validation, schema checking.

**Plan:** Use `gh-actions-language-server`. Requires a GitHub Personal Access
Token (PAT) for fetching action metadata from the API.

**Next steps:**
- Generate a PAT with appropriate scopes
- Check if Mason has `gh-actions-language-server` or manual install needed
- Configure yamlls filetype detection for GitHub Actions workflow files
- Test with existing workflows

### 10. Java stack

**Status:** Deferred

**Goal:** Full Java IDE support — LSP, formatting, debugging.

**Plan:**
- LSP: `jdtls` (complex setup, needs separate config — not a simple `servers` table entry)
- Formatter: google-java-format or built-in jdtls formatting
- Debugger: `java-debug-adapter` + `java-test` via nvim-dap
- Consider `nvim-jdtls` plugin for better jdtls integration

### 11. Python stack

**Status:** Deferred

**Goal:** Full Python IDE support — LSP, formatting, linting, debugging.

**Plan:**
- LSP: `pyright` (type checking, go-to-definition, completions)
- Formatter: `ruff` (fast, replaces black + isort) via conform.nvim
- Linter: `ruff` (replaces pylint, flake8) via nvim-lint
- Debugger: `debugpy` via nvim-dap
- Virtual env detection: pyright auto-detects `.venv`

### 12. TypeScript stack

**Status:** Deferred

**Goal:** Full TypeScript/JavaScript IDE support — LSP, formatting, linting.

**Plan:**
- LSP: `ts_ls` or `typescript-tools.nvim` (faster alternative)
- Formatter: `prettierd` via conform.nvim
- Linter: `eslint` via nvim-lint or eslint LSP
- Debugger: `js-debug-adapter` via nvim-dap

### 13. Dockerfile stack

**Status:** Deferred

**Goal:** Dockerfile/Docker Compose IDE support.

**Plan:**
- LSP: `dockerls` (Dockerfile) + `docker_compose_language_service` (compose files)
- Treesitter: `dockerfile` parser (add to ensure_installed)
- Linter: `hadolint` via nvim-lint (best practices, security checks)
- Formatter: built-in via LSP

### 14. Ansible stack

**Status:** Deferred

**Goal:** Ansible playbook/role IDE support.

**Plan:**
- LSP: `ansiblels` (Red Hat ansible-language-server)
- Treesitter: uses `yaml` parser
- Filetype detection: detect `playbook*.yml`, `tasks/*.yml`, `roles/**/*.yml` as `yaml.ansible`
- Linter: `ansible-lint` via nvim-lint

### 15. Neo-tree: expand only git-changed directories

**Status:** Research needed

**Goal:** A keybinding in neo-tree that expands only the directories containing
git-modified files, and stops at the directory level (doesn't expand deeper
into unchanged subdirectories). Like a "show me where the changes are" view.

**Approach:**
- Get list of changed dirs from `git diff --name-only`
- Walk the tree and expand only nodes on those paths
- Stop expansion at the deepest changed directory, don't recurse further
- Could be a custom neo-tree command mapped to a key like `gE`

### 16. HCL heredoc syntax highlighting (e.g., JSON inside `<<JSON`)

**Status:** Not working — needs investigation

**Problem:** JSON (and other languages) inside HCL/Terraform heredocs (`<<JSON ... JSON`)
renders as a single green string color instead of proper syntax highlighting.

**What's been tried:**
- The default nvim-treesitter injection query uses `#downcase!` on the heredoc
  identifier — this should work (`<<JSON` → json parser) but doesn't
- Explicit `after/queries/hcl/injections.scm` override using `#any-of?` + `#set!
  injection.language` instead of `#downcase!` — also didn't work
- JSON treesitter parser is installed and in `ensure_installed`
- No crash anymore (the old nvim 0.12 nil range bug seems fixed), but injection
  still silently fails

**Next steps:**
- Run `:InspectTree` with cursor inside a heredoc to check the parse tree
- Run `:lua print(vim.treesitter.get_parser():lang())` to verify injection is attempted
- Check `:checkhealth nvim-treesitter` for injection-related warnings
- Check if this is a known nvim-treesitter issue on GitHub
- JetBrains uses `#language json` comments for injection — no equivalent in treesitter

### 17. Extend smart fzf-tab fallback to more commands

**Status:** Open

**Goal:** The `_smart_tab` widget in `.zshrc` currently only intercepts `cd <word><Tab>`
to open fzf with all candidates when no prefix match exists. Extend this to other
commands where fuzzy directory/file search makes sense (e.g., `ls`, `cat`, `vim`,
`nvim`, `k edit`, `tg`, etc.).

**Context:** Before this, typing `cd helm<Tab>` showed nothing because zsh completion
only matches prefixes. The custom widget strips the partial word, lists all candidates
via glob, and passes the word as fzf `--query`. Currently only triggers for `cd`.

**Next steps:**
- Review aliases and common commands to decide which ones benefit from this
- For file-targeting commands (`cat`, `vim`, `nvim`, `less`), list files+dirs not just dirs
- For `cd`-like commands, keep dirs-only
- Consider making it generic: any command where normal completion returns 0 results

### 18. Git workflow keymaps

**Status:** Deferred

**Goal:** Quick keymaps for common git operations:
- `<Space>gp` — git pull (with output)
- `<Space>gP` — git push
- `<Space>gc` — git commit (maybe with Telescope for message)
- `<Space>gb` — git branch switch (Telescope picker)
- Consider `fugitive.nvim` or `neogit` for a full git UI inside nvim

Mason will auto-install them.

### 6. Set up debugger (nvim-dap)

**Status:** Deferred

**Goal:** Enable `kickstart.plugins.debug` for in-nvim debugging (breakpoints,
step through code, inspect variables). Needs per-language debug adapters:
- Python: `debugpy`
- Java: `java-debug-adapter`
- Go: `delve`
- TypeScript: `js-debug-adapter`

**Why deferred:** Most complex to set up. Useful when actively debugging,
not needed for config editing / learning phase.
- Test counting logic with single isolated edits first
- Consider debouncing: wait a short period after mtime change before diffing,
  in case multiple writes happen in quick succession

### 19. Evaluate snacks.picker as Telescope replacement

**Status:** Research needed

**Goal:** Try `folke/snacks.nvim` picker — the built-in file explorer mode looks
appealing. Could potentially replace both Telescope and neo-tree.

**Next steps:**
- Install and test `snacks.nvim` picker side-by-side with Telescope
- Compare file search, grep, LSP pickers
- Evaluate the explorer mode as a neo-tree alternative
- Check if all current Telescope keybindings have equivalents

### 20. Git workflow plugin

**Status:** Research needed

**Goal:** Full git UI inside nvim — staging, committing, branching, rebasing, log.

**Options to evaluate:**
- `tpope/vim-fugitive` — classic, well-proven, command-based (`:Git commit`, `:Git log`)
- `NeogitOrg/neogit` — Magit-inspired, interactive UI for staging hunks/lines
- `kdheepak/lazygit.nvim` — wraps lazygit TUI inside nvim

### 21. GitHub integration plugin

**Status:** Research needed

**Goal:** Browse PRs, issues, reviews, and CI checks without leaving nvim.

**Options to evaluate:**
- `pwntester/octo.nvim` — full GitHub integration (PRs, issues, reviews, comments)
- `ldelossa/gh.nvim` — lighter-weight PR review
- Check if any plugin integrates with `gh` CLI

### 22. Learn diff/compare workflow

**Status:** Learn

**Goal:** Efficient file comparison and change application in nvim, similar to
VSCode's compare editor.

**Topics to learn:**
- `:diffsplit file` — open side-by-side diff with another file
- `do` (diff obtain) / `dp` (diff push) — pull/push changes between sides
- `]c` / `[c` — jump between diff hunks
- `:DiffOrig` — compare unsaved buffer vs disk (already configured)
- Diffing two open buffers: `:windo diffthis` / `:diffoff!`
- Telescope git_status for reviewing changed files with preview
- Whether a plugin (e.g. diffview.nvim) adds value over built-in diff

### 23. Evaluate NvCheatsheet as in-nvim cheatsheet

**Status:** Research needed

**Goal:** Replace the external `~/nvim-cheatsheet` file with an in-nvim cheatsheet
plugin that can be opened with a keymap.

**Options to evaluate:**
- `NvChad/ui` (NvCheatsheet) — grid/column layout cheatsheet inside nvim
- `sudormrfbin/cheatsheet.nvim` — Telescope-searchable cheatsheet
- Check if which-key (`space` then wait) already covers most use cases

---

## Done

### Reload notification when file changes on disk

**Resolved:** Working via mtime-based approach.

**Solution:** Track file modification time (`vim.fn.getftime`) per buffer. On
`CursorHold`/`FocusGained`/`BufEnter`, compare current mtime against stored mtime.
If changed, run `checktime` and show `File reloaded from disk`. `BufWritePost` updates
stored mtime so user saves don't false-trigger.

**What failed along the way:**
- `FileChangedShell`/`FileChangedShellPost`: Don't fire when `autoread` is set
- `changedtick` comparison: `autoread` reloads before our callback runs
- `BufReadPost` content tracking: Fires on autoread reload, updating stored state prematurely
