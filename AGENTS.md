# Working in .dot

## Repository boundaries

`.dot` owns the public application configuration and its installers. `conf/`
is an ignored, independent Git repository containing private configuration.
It can be read and modified when relevant to the task; read `conf/AGENTS.md`
before working there. From this root, use `git -C conf status`,
`git -C conf diff`, and other `git -C conf ...` commands for its changes.
Parent Git operations do not include that repository. Keep reviews and any
requested commits separate, and never force-add `conf/` to the public repo.

`private/` is another local independent repository. The parent also ignores
`conf_pub/`, `conf_host/`, `conf_cloud_cn/`, `conf_cloud_global/`, and `scripts`;
ignore entries do not prove those directories exist. Resolve ownership before
working in them. Do not search all nested repositories or downloaded plugins
when a task only concerns the public configuration. Start with `git ls-files`
or a scoped `rg` search.

## Layout and installation

```text
.dot/
├── install.sh                public installer dispatcher
├── apps/
│   ├── <app>-install.sh      per-application installation
│   ├── zsh/                 core shell, prompt, plugins, and integrations
│   ├── nvim/                Lua/Vim config, plugin specs, tracked lockfile
│   ├── alacritty/           TOML config and downloaded themes
│   ├── zellij/              KDL overrides of upstream defaults
│   ├── tmux/                shared config, OS fragments, downloaded plugins
│   └── neomutt/             mail UI config; private account files excluded
├── gdb/gdbinit              standalone debugger config
├── conf/                    independent private configuration repository
├── private/                 separate private repository
```

`install.sh` resolves its location into `DOT_DIR`, discovers
`apps/*-install.sh`, and passes `DOT_DIR`, `APP_DIR`, `DOT_ZSH_DIR`, and
`DOT_LOG_LEVEL` to child installers. `-l` lists apps, repeatable `-i <app>`
installs selected apps, and `-a` installs all discovered non-test apps.
`test*` installers are scaffolding, excluded from listing and `-a` but still
reachable explicitly. Installation asks before each app and records failures.

Current installation targets (link location → repository source):

| Application | Link location | Source |
| --- | --- | --- |
| Zsh | `~/.zshrc` | `apps/zsh/zshrc` |
| Neovim | `~/.config/nvim` | `apps/nvim/` |
| Alacritty | `~/.config/alacritty` | `apps/alacritty/` |
| Zellij | `~/.config/zellij` | `apps/zellij/` |
| tmux | `~/.tmux`, `~/.tmux.conf` | `apps/tmux/`, `apps/tmux/tmux.conf` |

The current installers use `$HOME/.config` explicitly, not
`$XDG_CONFIG_HOME`. Shell files also assume the checkout is at `$HOME/.dot`,
even though the installer dispatcher can run from other checkout locations.
Do not claim arbitrary checkout or XDG support without tracing these consumers.
There are no current dispatcher installers for `neomutt/` or `gdb/`.

Symlinked source edits can take effect on the next application launch or
reload. Inspect links before editing an installed path. A folder being present
in `apps/` does not mean that app is installed on this host.

App installers use Bash with `set -euo pipefail` and share `apps/zsh/lib.sh`.
Use its `link_config` helper for new links. Identical links are a no-op; other
links are replaced, and existing files/directories enter a backup-or-delete
prompt flow. Installers can also download themes, clone/update plugins, and
bootstrap editor tooling. They are not read-only validation commands.
The Zsh installer also installs fzf and zoxide through the first available
supported package manager: Homebrew, apt, dnf, pacman, or apk. System package
managers run through `sudo` when the installer is not already root.

## Shell loading and configuration placement

The effective order starting at `apps/zsh/zshrc` is:

```text
base variables → core/prompt-options.zsh → compatible-gitstatus instant prompt → lib.sh
  → pre.zsh → optional hook-trace start warning
  → core/shell.zsh
  → post.zsh
      → core/prompt.zsh → Powerlevel10k with core/p10k.zsh
      → core/aliases.zsh for optional GNU replacements and shortcuts
      → core/integrations.zsh for fzf and zoxide
      → core/plugins.zsh for autosuggestions, then syntax highlighting last
      → optional hook-trace completion warning
```

Set `DOT_ZSH_TRACE_HOOKS=1` for a diagnostic shell that prints the pre/post
boundary warnings. This deliberately skips Powerlevel10k instant prompt for
that shell so the diagnostic output does not trigger its console-I/O warning.

Choose scope first, then execution phase:

| Scope | Placement |
| --- | --- |
| Pre/post extension points | `apps/zsh/{pre,post}.zsh` |
| Portable public shell behavior | `apps/zsh/core/shell.zsh` |
| Interactive aliases and GNU replacements | `apps/zsh/core/aliases.zsh` |
| Interactive tool integration | `apps/zsh/core/integrations.zsh` |
| ZLE plugins and load order | `apps/zsh/core/plugins.zsh` |
| Early and post-reset prompt policy | `apps/zsh/core/prompt-options.zsh` |
| Prompt loading and backend policy | `apps/zsh/core/prompt.zsh` |
| Powerlevel10k settings | `apps/zsh/core/p10k.zsh` |
| Shared personal configuration | `conf/app_conf/pub/zsh/00-zshrc-{pre,post}.sh` |
| Personal OS-specific configuration | `conf/app_conf/pub/zsh/10-{linux,macos}-{pre,post}.sh` |
| Host, employer, or project configuration | `conf/app_conf/pub/zsh/scene/20-*.sh` or its subdirectories |
| Initialization requiring final hook ownership | End of executable setup in `apps/zsh/zshrc` |

Private Zsh files remain in `conf/`, but `host-conf/` is currently disconnected
from both startup phases. Do not describe a private file as active merely
because it exists or is linked. Read `apps/zsh/host-conf/note.txt` before
reconnecting either phase. `pub` within `conf` means shared personal scope, not
public or secret-free.

Powerlevel10k loads first in `post.zsh`, followed by fzf and zoxide, then
autosuggestions and syntax highlighting. Syntax highlighting must remain last
so it sees the final ZLE widget set. The prompt uses an installed gitstatusd
only when its version satisfies Powerlevel10k's own platform metadata;
otherwise it uses Zsh's `vcs_info` fallback and never downloads a binary during
startup. Fallback shells skip instant prompt so a stale cache cannot start a
previously configured gitstatus daemon. Host config remains disconnected.
Prefer Zsh's native autoload mechanism for command-specific completion and add
other integrations individually only when needed.

The fzf integration prefers `fzf --zsh` and falls back to package-provided
`completion.zsh` and `key-bindings.zsh` files for older releases. Zoxide loads
after `compinit` and explicitly owns the `z` and `zi` commands. Aliases created
by `core/aliases.zsh` are tracked so re-sourcing it removes stale managed
aliases before applying the current table.

## Application-specific conventions

- Neovim: `init.lua` derives paths from its own location, bootstraps lazy.nvim,
  loads `plugins/install.lua`, then `plugins/setting.lua` and `config/`.
  Per-plugin settings live in `plugins/configs/`; Vimscript lives in
  `vimscripts/`. LSP and parser lists are shared with the installer through
  `lsp-servers.lua` and `treesitter-languages.lua`. Read `apps/nvim/doc/install.md`
  before changes. `lazy-lock.json` is tracked; runtime plugins, Mason, parsers,
  undo, backup, and swap data live under ignored `runtime/`. Old plugin-manager
  directories there are not authoritative configuration and may contain
  third-party instructions that do not govern this repository.
- Alacritty imports a downloaded Catppuccin theme from `plugins/`; the
  installer downloads the four flavours. Source configuration is tracked,
  downloaded themes are ignored except `plugins/README.md`.
- Zellij keeps only overrides of default settings in `config.kdl`. Preserve
  that approach. Its theme matches Alacritty; Powerlevel10k emits the prompt
  markers used by its scrollback integration.
- tmux's main config sources an OS fragment and invokes TPM under `~/.tmux`.
  The installer bootstraps TPM; plugins are installed through tmux. Keep
  downloaded `apps/tmux/plugins/` out of source edits.
- Neomutt references account configuration under `~/.mutt`; `*.info` and
  cache data are ignored. Do not copy private account values into public files.

## Portability and verification

Support Linux and macOS, including Intel and Apple Silicon. Keep host paths in
the private layer, guard Powerlevel10k with a file check, and do not export
`TERM`. README portability rules describe intended behavior, not proof every
existing file already satisfies them.

Check each relevant repository's status before editing and preserve unrelated
changes. Syntax-check each changed shell file separately using its actual
interpreter (`.sh` files sourced by Zsh can contain Zsh syntax):

```sh
bash -n install.sh
for f in apps/*-install.sh; do bash -n "$f" || break; done
for f in apps/zsh/zshrc apps/zsh/*.sh apps/zsh/*.zsh apps/zsh/core/*.zsh; do
    zsh -n "$f" || break
done
```

Passing several filenames to `bash -n` or `zsh -n` only checks the first
script; the rest become arguments. Syntax checks do not validate runtime
behavior. Loading a full shell can execute private hooks; an editor bootstrap
can download tooling and change lockfiles. Choose checks proportionate to the
task and report their limits. Keep README and app documentation aligned with
behavior changes, using implementation as the source of truth when old prose
disagrees.
