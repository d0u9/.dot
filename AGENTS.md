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
│   │   ├── bin/zsh-compile      byte-compilation command, on $PATH
│   │   ├── lib/compile.zsh      shared compilation targets and routine
│   │   ├── lib/toolcache.zsh    shared cache for tool-generated shell init
│   │   └── doc/completion.md    proposed completion registry (not implemented)
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

The current installers use `$HOME/.config` explicitly, not `$XDG_CONFIG_HOME`.
Do not claim XDG support without tracing these consumers.

Checkout location is not assumed. `install.sh` resolves `DOT_DIR` from its own
path, and `apps/zsh/zshrc` derives the same value from the location of the file
being sourced (`${${(%):-%x}:A:h:h:h}`, which resolves the `~/.zshrc` symlink),
then defines `DOT_ZSH_DIR` and `DOT_CONF_DIR` from it. Public and private shell
files locate everything through those three variables; `bin/zsh-compile`
resolves its own path the same way. Do not reintroduce a literal `~/.dot`, and
do not add a `~/.dot` fallback for them -- guessing would silently act on the
wrong tree on a host that keeps the checkout elsewhere.
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
managers run through `sudo` when the installer is not already root. Both tools
are optional: a host with no supported package manager gets a warning and a
working shell, not a failed install.

## Tracked configuration versus generated state

This repository is shared between machines, so the dividing line is what a
different machine could not reproduce for itself:

- Tracked: hand-written configuration and pinned versions. Everything under
  `apps/zsh/` except `host-conf/*.sh`, the Neovim configuration including
  `lazy-lock.json`, the Alacritty/Zellij/tmux/Neomutt sources, `gdb/gdbinit`,
  the installers, and the documentation.
- Generated inside the repository, ignored: `apps/nvim/runtime/*` (plugins,
  Mason, parsers, undo/backup/swap), `apps/tmux/plugins`, downloaded Alacritty
  themes under `apps/alacritty/plugins/*`, and `apps/zsh/host-conf/*.sh`.
- Generated outside the repository, per host: the Zsh plugin checkouts under
  `${XDG_DATA_HOME:-~/.local/share}/zsh/plugins` and the `.zwc` files compiled
  beside them; `${XDG_CACHE_HOME:-~/.cache}/zsh/` (`zcompdump-*` and its
  `.zwc`, `zcompcache/`, `gitstatus-probe`, `dircolors.zsh`, `fzf-init.zsh`,
  `zoxide-init.zsh`); Powerlevel10k's `p10k-*` caches and `~/.cache/gitstatus`;
  and the history file.

The rule that decides where regeneration belongs: the installer is for things
that must be fetched over the network -- plugin checkouts, downloaded themes,
packaged tools. Anything derived from what is already on the machine is
generated on demand by the shell that needs it, and is valid again after being
deleted, after an OS upgrade, or on a machine that has never run the installer.
Every cache listed above is rebuilt this way, including the plugins' `.zwc`,
which `core/plugins.zsh` refreshes when a compiled file is missing or older
than its source and `zsh-compile` rebuilds on request. Do not move any of them
into the installer, and do not commit generated output to make another machine
skip the work: a `.zwc` is tied to the Zsh version that wrote it, and a
completion dump to the host's `fpath`.

`~/.local` is the account's install prefix: what this user installed without
root and outside any package manager. `core/shell.zsh` puts `~/.local/bin` on
`$PATH`; `~/.local/lib` holds unpacked toolchains and SDKs, and
`~/.local/share/man` their manual pages, both referenced from the private
layer. It replaces an older `~/Apps` tree that used private names for the same
layout -- `~/.local` is what rustup, pipx, uv and most `curl | sh` installers
already target, so nothing has to be redirected to land there. Its content is
per-architecture, machine-local, and belongs to the generated category above:
never committed, and reproduced by fetching, not by copying between hosts.
Nothing in this repository installs into it yet, so a binary placed there by
hand has no recorded provenance or update path; an installer that fetches by
`uname -s`/`uname -m` is where that belongs.

`core/p10k.zsh` is tracked and hand-edited, but it is also what
`POWERLEVEL9K_CONFIG_FILE` points at, so running `p10k configure` overwrites a
tracked file and discards the hand-written customizations. Edit it
directly instead.

## Shell loading and configuration placement

The effective order starting at `apps/zsh/zshrc` is:

```text
base variables → core/prompt-options.zsh → instant prompt → lib.sh
  → pre.zsh → optional hook-trace start warning
  → core/shell.zsh for options, $PATH, completion and key bindings
  → post.zsh
      → core/prompt.zsh → Powerlevel10k with core/p10k.zsh
      → core/aliases.zsh for optional GNU replacements and shortcuts
      → core/integrations.zsh for fzf and zoxide
      → core/plugins.zsh: byte-compile, then autosuggestions, then syntax
        highlighting last
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
| Logic shared by startup and commands | `apps/zsh/lib/*.zsh` |
| A command the user runs by name | `apps/zsh/bin/*` |
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
so it sees the final ZLE widget set. Before sourcing them, `core/plugins.zsh`
byte-compiles anything out of date, using `lib/compile.zsh`. Its targets are
the plugin files this configuration sources and the configuration's own files;
Powerlevel10k compiles itself, `zshrc` is opened as `~/.zshrc` so its `.zwc`
would land outside the repository, and the highlighter test data no shell
reads is excluded. That check costs about 2.6ms and saves about 15ms. A `.zwc`
older than its source is ignored by Zsh, so a missed recompilation is slower,
never stale, and a plugin directory that is not writable simply goes
uncompiled.

`bin/zsh-compile` performs the same work explicitly -- `zsh-compile` for what
is out of date, `force` for everything, `clean` to remove the compiled files,
`prune` for orphans, `list` to show their state -- and the installer calls it
after updating the plugin checkouts. Zsh sources a `.zwc` even when its source
file is gone, and `.zwc` files are untracked, so git never removes one: after
deleting or renaming a configuration file, or checking out a commit that
predates it, the shell keeps running the old file until `prune` removes it. `core/shell.zsh` puts `apps/zsh/bin` on `$PATH`, so it is
reachable by name. All three paths share `lib/compile.zsh`, so the target list
cannot drift between them; add a target there, not in a caller. The prompt uses an installed gitstatusd
only when its version satisfies Powerlevel10k's own platform metadata;
otherwise it uses Zsh's `vcs_info` fallback and never downloads a binary during
startup. That compatibility answer is cached under `$XDG_CACHE_HOME/zsh` and
keyed on the sizes and modification times of Powerlevel10k's gitstatus
installer and of the daemon it resolved, so the probe forks only after one of
them changes. Fallback shells keep instant prompt and instead delete an instant
prompt cache that still carries a `_p9k_preinit` function, which is the only
part of that cache able to start a daemon this host has rejected. Host config
remains disconnected.

Prefer Zsh's native autoload mechanism for command-specific completion and add
other integrations individually only when needed. `apps/zsh/doc/completion.md`
is a design proposal for a completion registry and refresh command; it is not
implemented, so do not describe any part of it as current behavior.

The fzf integration prefers `fzf --zsh` and falls back to package-provided
`completion.zsh` and `key-bindings.zsh` files for older releases. Zoxide loads
after `compinit` and explicitly owns the `z` and `zi` commands. Both init
scripts, and GNU `dircolors` output, go through `lib/toolcache.zsh`, which
caches them as generated files under `$XDG_CACHE_HOME/zsh` and re-sources them
from there, so startup forks none of the three. Each cache's first line records
the generating command and a fingerprint of the resolved executable -- path,
size and modification time -- and is regenerated when either changes. Do not
replace that with a timestamp comparison against the cache: a Homebrew install
is a symlink into `Cellar/<version>/`, test operators follow it, and the
bottle's build time is normally older than the cache it would need to
invalidate. Zoxide's `chpwd` hook is copied
and replaced by one that runs the original in a disowned background job:
`zoxide add` takes about 29ms to start against 3.5ms for a plain fork, and
paying that between Enter and the next prompt made every `cd` visibly slower
(about 85ms against 31ms for two `cd`s). The database is written a moment
after the `cd` instead of during it. Aliases created
by `core/aliases.zsh` are tracked so re-sourcing it removes stale managed
aliases before applying the current table.

### Optional tool initialization and explicit fallback lists

Before running any tool-generated initialization such as
`eval "$(xxx init zsh)"`, check that the executable exists with
`(( $+commands[xxx] ))`. This applies to cached initialization too: never
source a stale init script for a missing tool. Keep the check visible at the
integration call site, and retain the shared guard in `lib/toolcache.zsh`.
Also verify the resolved path is executable: Zsh's command hash can survive
an uninstall. Fallback selection must likewise skip these stale entries.
Missing optional tools must be skipped without command-not-found errors.

Command replacement priority is platform-specific:

- macOS: preferred modern replacement (for example `eza`) -> GNU command
  (for example `gls`) -> platform default (`ls`).
- Linux: preferred modern replacement (for example `eza`) -> default command
  (`ls`), without trying a separate `g`-prefixed GNU command first.

Declare candidates in the clearly labeled `macos_fallbacks` and
`linux_fallbacks` lists in `apps/zsh/core/aliases.zsh`, ordered from left to
right. Add or change priorities there, not in scattered executable checks.
Each row maps a command to candidate executable names; the first installed
candidate wins. Tools without a modern replacement start at the next tier.
Optional helpers such as dircolors use the same lists and are skipped if no
candidate exists. Keep implementation-specific flags in separate presets
(notably eza versus ls), and only alias replacements with compatible command
interfaces. Re-sourcing must remove stale managed aliases before selection.

## Application-specific conventions

- Neovim: `init.lua` derives paths from its own location, bootstraps lazy.nvim,
  loads `plugins/install.lua`, then `plugins/setting.lua` and `config/`.
  Per-plugin settings live in `plugins/configs/`; common Lua settings live in
  `config/`, with language-local overrides in `after/ftplugin/`. LSP and parser
  lists are shared with the installer through
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
