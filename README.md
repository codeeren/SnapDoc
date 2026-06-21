# SnapDoc

The macOS answer to the Windows **New ▸ Word / Excel / Text …** right-click menu.
Create a new file (or folder) in the active Finder folder with a single click.

It works two ways:

- **Menu bar**: click the menu-bar icon → pick a type → the file is created in the
  frontmost Finder window's folder (or the Desktop) and selected in Finder.
- **Right-click**: right-click in a Finder folder (empty space works too) → a single
  **"New ▸"** item; hover it to reveal the file-type submenu.

Localized in **English** and **Turkish** (follows the system language).

## Install

Two flavors:

### 🟦 SnapDoc Lite — via DMG (easy)
Download `SnapDoc.dmg` from [Releases](../../releases) → open it → drag **SnapDoc** to
`Applications`. On first launch, if Gatekeeper warns: **System Settings > Privacy &
Security** → **Open Anyway**.

> **The DMG build supports creating documents from the menu bar. The Finder
> right-click integration only works reliably when the app is built locally from
> source, due to macOS code-signing and extension restrictions** (see *SnapDoc Full*).

(Requires an Apple Silicon / arm64 Mac.)

### 🟩 SnapDoc Full — build from source (right-click works)
For the Finder right-click menu to work, build the app with your own Apple ID — macOS
only registers Finder extensions signed with a locally valid certificate:

```sh
git clone https://github.com/codeeren/SnapDoc.git
cd SnapDoc
./build.sh
```

See **Building** below for prerequisites.

## File types

Folder, Text (.txt), Markdown (.md), CSV (.csv), JSON (.json), HTML (.html),
Python (.py), Shell Script (.command), Word (.docx), Excel (.xlsx), PowerPoint (.pptx).

Add or remove a type by editing one file: `NewFileKit/FileCatalog.swift`.

> Empty `.docx/.xlsx/.pptx` files aren't valid; SnapDoc copies them from valid blank
> templates in `NewFileKit/Resources/`.

## Architecture

```
SnapDoc.app                  (LSUIElement — no Dock icon, menu bar only)
├─ App/                      menu bar (NSStatusItem) + RequestWatcher
├─ NewFileKit.framework      shared catalog + file creation + templates + localization
└─ FinderSyncExt.appex       Finder Sync extension (right-click submenu, SANDBOXED)
```

`App` and `FinderSyncExt` both use the shared `NewFileKit` framework. All user-facing
strings live in `NewFileKit` (en + tr) so both processes share one translation table.

### macOS hurdles solved (developer notes)

Worth documenting, because each one silently breaks the app:

1. **ASCII bundle name.** Non-ASCII characters in the bundle/executable name break
   codesign (`code object is not signed at all`). Keep `PRODUCT_NAME` ASCII; use
   `CFBundleDisplayName` for a localized display name.
2. **Apple Development certificate required.** macOS Tahoe refuses to register an
   ad-hoc-signed Finder Sync extension. A (free) Apple ID + "Personal Team" in Xcode
   is needed (`DEVELOPMENT_TEAM` is baked into `project.yml`).
3. **The extension must be sandboxed.** `pkd` silently rejects a non-sandboxed Finder
   Sync extension. `app-sandbox = true` + file-access path exceptions.
4. **Menu actions don't fire with `target=self`.** The menu is drawn in Finder's
   process, so actions must travel the responder chain; the chosen type is carried in
   `NSMenuItem.tag`.
5. **Quarantine / "damaged".** The sandbox stamps `com.apple.quarantine` on created
   files and won't let the extension remove it → `.command` files appear "damaged".
   Fix: the extension drops a request in `/Users/Shared/SnapDoc/`; the non-sandboxed
   app (`RequestWatcher`) removes the quarantine — but only if the quarantine agent is
   our own extension (confused-deputy protection).

## Building

**Prerequisites (once):**

1. **Full Xcode** installed (`sudo xcode-select -s /Applications/Xcode.app`).
2. **Sign into Xcode** with an Apple ID: Xcode > Settings > Accounts > "+" (free).
3. **XcodeGen**: `brew install xcodegen`.

**Build + install + enable the extension (one command):**

```sh
./build.sh
```

It generates the project, builds with automatic signing, installs to `/Applications`,
registers with LaunchServices, launches the app, and enables the Finder extension.

> On first run, enable the Finder Sync extension under System Settings > General >
> Login Items & Extensions if it isn't already on. The first menu-bar use asks for
> Finder automation (Apple Events) permission → Allow.

## Notes / limitations

- `DEVELOPMENT_TEAM` in `project.yml` is machine-specific; replace it with your own
  Apple ID team ID when building on another machine.
- **Certificate lifetime:** a free Apple Development certificate is valid ~1 year
  (macOS has no iOS-style 7-day limit). Rebuild with `./build.sh` when it expires.
- `.command` de-quarantine needs the menu-bar app running (the login item guarantees
  this). All other types are created fine even when the app is closed.

## License

MIT
