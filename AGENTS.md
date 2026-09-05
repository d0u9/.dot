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
│   ├── omz/                 shared shell, OS branches, host link entry points
│   ├── nvim/                Lua/Vim config, plugin specs, tracked lockfile
│   ├── alacritty/           TOML config and downloaded themes
│   ├── zellij/              KDL overrides of upstream defaults
│   ├── tmux/                shared config, OS fragments, downloaded plugins
│   └── neomutt/             mail UI config; private account files excluded
├── gdb/gdbinit              standalone debugger config
├── conf/                    independent private configuration repository
├── private/                 separate private repository
└── install.sh_old           historical installer
```

`install.sh` resolves its location into `DOT_DIR`, discovers
`apps/*-install.sh`, and passes `DOT_DIR`, `APP_DIR`, `DOT_OMZ_DIR`, and
`DOT_LOG_LEVEL` to child installers. `-l` lists apps, repeatable `-i <app>`
installs selected apps, and `-a` installs all discovered non-test apps.
`test*` installers are scaffolding, excluded from listing and `-a` but still
reachable explicitly. Installation asks before each app and records failures.

Current installation targets (link location → repository source):

| Application | Link location | Source |
| --- | --- | --- |
| OMZ | `~/.zshrc` | `apps/omz/zshrc` |
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

App installers use Bash with `set -euo pipefail` and share `apps/omz/lib.sh`.
Use its `link_config` helper for new links. Identical links are a no-op; other
links are replaced, and existing files/directories enter a backup-or-delete
prompt flow. Installers can also download themes, clone/update plugins, and
bootstrap editor tooling. They are not read-only validation commands.

## Shell loading and configuration placement

The effective order starting at `apps/omz/zshrc` is:

```text
base variables/plugins → lib.sh
  → omz-pre.sh
      → macos/macos-pre.sh OR linux/linux-pre.sh
      → shared plugin/tool setup
      → host-conf/*-pre.sh, sorted
  → $ZSH/oh-my-zsh.sh
  → omz-post.sh
      → matching platform post file
      → shared functions, Pure prompt, OSC 133 hooks
      → host-conf/*-post.sh, sorted
  → final initialization in zshrc (currently zoxide)
```

Choose scope first, then execution phase:

| Scope | Placement |
| --- | --- |
| Portable public shell behavior | `apps/omz/omz-{pre,post}.sh` |
| Public OS-specific behavior | `apps/omz/{macos,linux}/` |
| Shared personal configuration | `conf/app_conf/pub/omz/00-zshrc-{pre,post}.sh` |
| Personal OS-specific configuration | `conf/app_conf/pub/omz/10-{linux,macos}-{pre,post}.sh` |
| Host, employer, or project configuration | `conf/app_conf/pub/omz/scene/20-*.sh` or its subdirectories |
| Initialization requiring final hook ownership | End of executable setup in `apps/omz/zshrc` |

The private files become active through selected symlinks in
`apps/omz/host-conf/`. Preserve the target basename: `00` means shared,
`10` means platform, `20` means scene, not unique sequence numbers. Each
private `00` file sources the matching private `10` file itself; do not link
both for the same phase. A scene file is selected explicitly; its presence in
`conf/` does not load it. Read `apps/omz/host-conf/note.txt` for the link pattern.
`pub` within `conf` means shared personal scope, not public or secret-free.

As observed on 2026-09-06, `host-conf/` contains only `note.txt`, so that entry
point enables no private shell files on this host. Recheck links when needed;
do not turn this observation into a permanent assumption.

Plugin selection belongs before OMZ loads. Pure and OSC 133 hooks live after
OMZ; preserve the documented order that captures exit status before Pure and
appends the prompt-end marker after prompt setup. Check existing definitions
and hooks when introducing a command such as `z`: `fasd` and `jump` have
conditional setup in `omz-pre.sh`, and host configuration may add more.

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
  that approach. Its theme matches Alacritty, and shell helpers/prompt markers
  are implemented in OMZ post configuration.
- tmux's main config sources an OS fragment and invokes TPM under `~/.tmux`.
  The installer bootstraps TPM; plugins are installed through tmux. Keep
  downloaded `apps/tmux/plugins/` out of source edits.
- Neomutt references account configuration under `~/.mutt`; `*.info` and
  cache data are ignored. Do not copy private account values into public files.

## Portability and verification

Support Linux and macOS, including Intel and Apple Silicon. Guard optional
tools with `command_exist` and optional plugins/themes with directory checks.
Use `$HOMEBREW_PREFIX` where available; platform detection probes
`/opt/homebrew` before `/usr/local`. Keep host paths in the private layer.
Guard terminal-only operations with `[ -t 0 ]`, do not export `TERM`, and
preserve lazy runtime-manager loading rather than adding unconditional startup
cost. README portability rules describe intended behavior, not proof every
existing file already satisfies them.

Check each relevant repository's status before editing and preserve unrelated
changes. Syntax-check each changed shell file separately using its actual
interpreter (`.sh` files sourced by Zsh can contain Zsh syntax):

```sh
bash -n install.sh
for f in apps/*-install.sh; do bash -n "$f" || break; done
for f in apps/omz/zshrc apps/omz/*.sh apps/omz/macos/*.sh apps/omz/linux/*.sh; do
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
