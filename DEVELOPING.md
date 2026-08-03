# Developing

The SDK is a thin native wrapper (`Crisp` → `CrispChatBox` → `CrispChatBoxFFI`) around the
`crisp-client` web chatbox, which runs in a `WKWebView`. The web client is pulled
from a private npm registry, baked into an `xcframework` (`CrispClient`), and
bridged to Swift through a generated JS FFI layer.

## Prerequisites & first-time setup

Everything is driven by [`mise`](https://mise.jdx.dev). Tool versions (Xcode,
SwiftFormat, SwiftLint, CocoaPods, node, ruby, jq, …) are pinned in
`.mise/config.toml` and `.xcode-version`.

```sh
mise install                 # install the pinned toolchain
mise run fetch-crisp-client  # REQUIRED before the first build (see next section)
```

Then open `CrispSDK.xcworkspace` (or the package directly in Xcode).

`fetch-crisp-client` needs credentials for the private npm registry — set
`NPM_PULL_TOKEN` to the contents of the registry `.npmrc`. (or store that `.npmrc`
in 1Password as a document named `Crisp SDK npm Pull Token` and the
tasks will read it via `op`).

## The `CrispClient` target: dev / local / release modes (read this first)

`Sources/CrispClient/` is **generated and gitignored**. It holds the web client
bundle (`dist/`) plus the generated `CrispWebClient.swift` glue. A fresh checkout
does not contain it, which is why the first build needs `fetch-crisp-client`.

The `CrispClient` target in `Package.swift` is rewritten by
`mise run set-crisp-client-target <mode>` (between the `mise:crisp-client-target`
markers):

| Mode      | `CrispClient` is…                                    | Set by                            |
| --------- | ---------------------------------------------------- | --------------------------------- |
| `dev`     | a **source** target (`Sources/CrispClient` + `dist`) | `fetch-crisp-client`              |
| `local`   | a prebuilt **`CrispClient.xcframework`** on disk     | `build-crisp-client-framework`    |
| `release` | a **remote** xcframework (url + checksum)            | the release process (on `master`) |

`develop` is committed in **`dev`** mode; `master` in **`release`** mode (see
[Branching](#branching-model--why)). If the package stops resolving
("no such module CrispClient" / missing `dist`), you're in the wrong mode — run
`fetch-crisp-client`.

## Building, running & testing

- **DemoApp** — the `DemoApp` scheme. It needs a Crisp **Website ID**: enter one
  in the app's Settings tab, or set the `WEBSITE_ID` env var (persisted across
  launches).
- **Tests** — `mise run test` runs the `AllTests` plan (CrispChatBox + CrispChatBoxFFI unit
  tests + the DemoApp UI smoke test) and the codegen macro tests. Tests build
  `CrispClient` **from source** (dev mode).

  The UI smoke test (`ChatBoxSmokeTests`) reads a Crisp **Website ID** from
  `WEBSITE_ID` in the test runner's environment and fails if it's absent. CI
  injects it from a secret via `TEST_RUNNER_WEBSITE_ID` (the `TEST_RUNNER_`
  prefix forwards an env var into the separate UI-test runner process). To run
  the suite locally, pass one the same way:

  ```sh
  # bash / zsh
  TEST_RUNNER_WEBSITE_ID=<website-id> mise run test
  # or fish
  env TEST_RUNNER_WEBSITE_ID=<website-id> mise run test
  ```

- **Formatting / linting** — `mise run format` (`f`), `mise run lint` (`l`). CI
  enforces both.

## Upgrading the crisp-client (chatbox) version

The version is pinned in `.crisp-client-version`. The strings catalog is generated
from the **same** release, so the pin and the catalog move together — and
`update-crisp-client` is the only task that moves them (builds/fetches only _read_
the pin, so a build never rewrites tracked files).

```sh
mise run update-crisp-client [version]   # alias: update-cc; defaults to 'latest'
```

This resolves the version (a range/dist-tag becomes the concrete version npm
served), writes `.crisp-client-version`, and regenerates the strings catalog. Then
pick up the new client locally:

```sh
mise run fetch-crisp-client            # dev/source mode
# or: mise run build-crisp-client-framework   # binary mode
```

Commit `.crisp-client-version`, the regenerated
`Sources/CrispChatBox/Assets/Localizable.xcstrings`, and `.swiftpolyglot.json`. CI fails
if the catalog doesn't match the pin.

> Developing against a **local** crisp-client checkout? `mise run bundle-crisp-client <path>`
> builds the dev bundle from that checkout instead of npm.

## FFI / JS-bridge layer & codegen

The Swift⇄JS bridge is written with custom macros, but the **shipped root package
has no swift-syntax dependency** — it vends pre-expanded plain Swift. That
expansion is a build-time step, not a compile-time macro.

- **Authored** sources (with the `@JSClass`/`@JSMethod`/… macros) live under
  `codegen/Sources/**` — e.g. `codegen/Sources/CrispChatBoxFFI/CrispClient.swift` and
  `Macros.swift`. The macro _implementations_ are the `ChatBoxJSMacros` target in
  the `codegen/` package.
- Run the expander:

  ```sh
  mise run codegen
  ```

  `MacroExpander` reads `codegen/Sources/**`, expands the macros, and writes plain
  Swift to the mirrored path under root `Sources/**` (each generated file starts
  with a `// Source: codegen/Sources/…` banner), then swiftformats.

**Rules:**

- Never hand-edit generated files under `Sources/CrispChatBoxFFI/…` — edit the authored
  source in `codegen/…` and re-run `mise run codegen`.
- Never add swift-syntax / macro dependencies to the root `Package.swift`.
- Macro unit tests: `swift test --package-path codegen` (also part of `mise run test`).
- CI fails if generated sources are stale ("Check generated sources are up to date").

## Localization / strings catalog

`Sources/CrispChatBox/Assets/Localizable.xcstrings` is **generated** from crisp-client's
per-locale JSON (the `_strings.sdk` group) — do not hand-edit it.

- Regenerated by `update-crisp-client` (version bump) or, against the current pin,
  `mise run generate-strings-catalog`. `.swiftpolyglot.json`'s language list is
  regenerated alongside it.
- `mise run validate-translations` checks completeness. CI runs both a drift check
  and validation.

## Branching model & why

- **`develop`** — the working branch. `Package.swift` is committed in **dev/source**
  mode (`CrispClient` built from `Sources/CrispClient`). All feature work and PRs
  target `develop`.
- **`master`** — the **release** branch. Each release rebases `master` onto
  `develop`, flips `Package.swift` to **release** mode (remote xcframework url +
  checksum), commits that one change, and **force-pushes**. So `master` is always
  exactly one commit ahead of `develop` and never diverges.
- **Tags** (`x.y.z`) are immutable pointers to each release's `master` commit — past
  releases stay reachable via their tag even though `master` is rewritten.

**Why:** consumers want a `Package.swift` that points at the prebuilt binary (fast,
no web-client build, no npm credentials), while maintainers develop against source.
Those two modes can't live in one committed file, so the release process owns the
flip and `master` carries the released shape.

CI reflects this: `tests` runs on PRs to `develop`; `publish_docs` and `release`
check out `develop` and build from source (running `fetch-crisp-client` /
`build-crisp-client-framework` as needed).

## Cutting a release

Manual only — **[Run workflow](https://github.com/crisp-im/crisp-sdk-ios/actions/workflows/release.yml)**, with the version (e.g. `3.0.0` or `3.0.0-beta.1`).

Prerequisite: a `release-notes/<version>.md` file must exist (the task aborts
without it).

The release: builds + signs the `CrispClient.xcframework`, bumps
`ChatBoxVersion.swift`, commits on `develop`, rewrites `master` in release mode,
tags, creates the GitHub release (uploads the xcframework zip + the CocoaPods
archive), and `pod trunk push`es the three pods. A version containing `beta` is
marked as a GitHub **pre-release**.

## Required secrets & refreshing them

GitHub Actions secrets (names only):

- **`NPM_PULL_TOKEN`** — the `.npmrc` contents for the private crisp-client npm
  registry; used by every task that fetches the web client. _Refresh:_ regenerate
  the registry pull token, then update the GitHub secret.
- **`COCOAPODS_TRUNK_TOKEN`** — auth for `pod trunk push`. _Refresh:_
  `pod trunk register <email> 'Crisp' --description=…`, then copy the token from
  `~/.netrc` (machine `trunk.cocoapods.org`).
- **`CERTIFICATE`** — base64 of the Apple **Distribution** signing `.p12`, used to
  sign the xcframework. _Refresh when it expires:_ export the distribution cert +
  private key from Keychain as a `.p12`, `base64` it, update the secret.
  The `setup_certificates` CI step fails early with an explicit "certificate expired"
  message.
- **`WEBSITE_ID`** — a Crisp Website ID for the UI smoke test (forwarded as
  `TEST_RUNNER_WEBSITE_ID`). _Refresh:_ any valid Website ID.
- **`GITHUB_TOKEN`** — provided automatically by Actions; nothing to manage.

For **local** work you only need `NPM_PULL_TOKEN` (or a document in 1Password
named `Crisp SDK npm Pull Token` containing the credentials). Signing, trunk, and
Website-ID secrets are release/CI concerns.
