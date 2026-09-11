# Open Terminal Here

A tiny macOS utility you pin to the **Finder toolbar**. Click it and a Terminal
window opens, already `cd`'d into the folder you're currently viewing in Finder.

Two variants are included:

- **`Open Terminal Here (Universal).app`** — opens the standard macOS **Terminal**.
- **`Open iTerm2 Here (Universal).app`** — opens **[iTerm2](https://iterm2.com)**
  (a new window with your default profile). Requires iTerm2 to be installed.

It's a modern, native replacement for the classic
[**cd to**](https://github.com/jbtule/cdto) utility, which was an Intel-only
(x86_64) binary. As Apple winds down Rosetta 2, those old builds show a *"not
compatible with a future version of macOS"* warning. This version is built as an
AppleScript app, so its runtime is a **universal binary (Apple Silicon + Intel)**
and never depends on Rosetta.

## Install

1. Download / clone this repo.
2. Build the apps (or use the prebuilt ones in the repo):
   ```sh
   ./build.sh
   ```
3. Move the variant you want (or both) to `/Applications`.
4. First launch: right-click the app → **Open** (it's ad-hoc signed, so Gatekeeper
   asks once). Grant the **Automation** permission it requests for Finder and
   Terminal (or iTerm2).
5. Pin it to the toolbar: open a Finder window, then **⌘-drag** the app onto the toolbar.

## Usage

Click the toolbar icon while viewing any folder → your terminal opens there.

Like the classic *cd to*, the **selection takes priority** over the folder being
viewed: with a file selected, the terminal opens in the folder *containing that
file* — handy in list view, where a selected file can sit inside an expanded
subfolder deeper than the folder you're viewing. A selected folder opens that
folder itself, and a selected alias resolves to its original item first. With
nothing selected, the front window's folder is used; with no Finder window
open, it falls back to your Desktop.

## Build from source

The apps are generated from
[`src/OpenTerminalHere.applescript`](src/OpenTerminalHere.applescript) and
[`src/OpenITerm2Here.applescript`](src/OpenITerm2Here.applescript) by
[`build.sh`](build.sh), which compiles them, sets the icon, and ad-hoc signs
them. Building the iTerm2 variant requires iTerm2 to be installed (the
AppleScript compiler needs its scripting dictionary).

## Playing nice with a tmux auto-attach

If your `~/.zshrc` auto-attaches tmux in interactive shells, the `cd` these
apps send would land inside the tmux session instead of a fresh shell. The two
variants signal your zshrc differently:

- **iTerm2 variant:** launches its window's login shell with `OPENTERMHERE=1`
  in the environment (via the profile's command). This is race-free even when
  the click cold-starts iTerm2 and its own startup window's shell is
  initializing at the same time.
- **Terminal variant:** Terminal's `do script` can't inject environment, so
  the app touches a flag file (`/tmp/opentermhere-skip-tmux-$USER`) just
  before opening the window, and your zshrc consumes it. If Terminal isn't
  running yet, the app launches it and waits for the startup window's shell
  to finish initializing first, so that shell can't steal the flag.

A zshrc block that supports both — and only auto-attaches in a real terminal
window or ssh login, so embedded shells spawned by other apps (IDEs, AI
assistants, …) don't pile up as tiny tmux clients that shrink the session:

```zsh
if [[ $- == *i* && -z $TMUX && -z $OPENTERMHERE ]] \
    && [[ -n $SSH_CONNECTION || $TERM_PROGRAM == "Apple_Terminal" || $TERM_PROGRAM == "iTerm.app" ]] \
    && command -v tmux >/dev/null; then
  _oth_flag="/tmp/opentermhere-skip-tmux-$USER"
  if [[ -f $_oth_flag ]] && (( $(date +%s) - $(stat -f %m "$_oth_flag") < 15 )); then
    rm -f "$_oth_flag"   # toolbar-app window: plain shell, consume the flag
  else
    tmux attach -t main 2>/dev/null || exec tmux new -s main
  fi
  unset _oth_flag
fi
```

Both signals are harmless if your zshrc ignores them, and the flag's 15-second
freshness check means a stale flag can't suppress a later attach.

## Customizing

- **Another terminal emulator:** copy one of the sources, change the
  `tell application` block to target it, and add a `build_app` line in
  `build.sh`.
- **New tab instead of new window:** adjust the `do script` call (Terminal) or
  the `create window with default profile` call (iTerm2).

## License

GPL-3.0 — see [LICENSE](LICENSE).

The application icon is from the original *cd to* project. The iTerm2 variant's
icon is derived from it by [`src/make_iterm_icon.swift`](src/make_iterm_icon.swift),
which swaps the white `>_` for an iTerm2-style green `$` and block cursor.
