# Open Terminal Here

A tiny macOS utility you pin to the **Finder toolbar**. Click it and a Terminal
window opens, already `cd`'d into the folder you're currently viewing in Finder.

It's a modern, native replacement for the classic
[**cd to**](https://github.com/jbtule/cdto) utility, which was an Intel-only
(x86_64) binary. As Apple winds down Rosetta 2, those old builds show a *"not
compatible with a future version of macOS"* warning. This version is built as an
AppleScript app, so its runtime is a **universal binary (Apple Silicon + Intel)**
and never depends on Rosetta.

## Install

1. Download / clone this repo.
2. Build the app (or use the prebuilt one in the repo):
   ```sh
   ./build.sh
   ```
3. Move **`Open Terminal Here (Universal).app`** to `/Applications`.
4. First launch: right-click the app → **Open** (it's ad-hoc signed, so Gatekeeper
   asks once). Grant the **Automation** permission it requests for Finder and Terminal.
5. Pin it to the toolbar: open a Finder window, then **⌘-drag** the app onto the toolbar.

## Usage

Click the toolbar icon while viewing any folder → Terminal opens there. If no
Finder window is open, it falls back to your Desktop.

## Build from source

The app is generated from [`src/OpenTerminalHere.applescript`](src/OpenTerminalHere.applescript)
by [`build.sh`](build.sh), which compiles it, sets the icon, and ad-hoc signs it.

## Customizing

- **iTerm2 instead of Terminal:** change the `tell application "Terminal"` block
  in the source to target iTerm, then rebuild.
- **New tab instead of new window:** adjust the `do script` call.

## License

GPL-3.0 — see [LICENSE](LICENSE).

The application icon is from the original *cd to* project.
