# Notes and TODO

This tap is intentionally private-tap pragmatic. It is built for Solus Linux
with Homebrew installed at `/home/linuxbrew/.linuxbrew`, and it favors native
desktop integration over strict upstream Homebrew style.

## Private-tap compromises

- The casks install into `/opt` with `sudo` because these GUI apps expect native
  Linux desktop integration outside the Homebrew prefix.
- `1password-native` follows 1Password's generic tarball instructions and runs
  upstream `after-install.sh`.
- GitKraken and Zen generate desktop entries because their tarball artifacts are
  not distro packages.
- Current smoke-test casks use `version :latest` and `sha256 :no_check`.
- The casks are x86_64-only because Solus x86_64 is the primary target.
- Uninstall removes only the `/opt` application directories and system links or
  desktop files created by these casks. User data is only listed in `zap`.

## Before proposing anything upstream

- Replace `version :latest` and `sha256 :no_check` with versioned URLs and
  checksums where upstream supports them.
- Confirm Homebrew's current Linux cask expectations for `/opt`, sudo, desktop
  files, and non-macOS GUI apps.
- Replace procedural shell in casks with more idiomatic DSL artifacts if the
  Linux cask implementation supports the target layout cleanly.
- Add automated audit/style CI against current Homebrew.
- Add livecheck blocks for vendors with stable machine-readable release feeds.
- Consider whether these belong in Homebrew at all, since Homebrew's public cask
  policy and Linux GUI app support may reject sudo `/opt` installers.
- Confirm 1Password native messaging, SSH agent, and browser integration on a
  clean Solus install after every major cask change.

## Unresolved vendor URL/checksum issues

- 1Password publishes a stable `1password-latest.tar.gz` URL for generic Linux.
  A detached signature is available, but this tap does not yet verify it.
- GitKraken publishes an official unversioned Linux tarball URL. A simple
  versioned tarball URL and checksum source were not exposed in the install docs.
- Zen Browser's GitHub releases expose stable asset names. The cask uses the
  official `releases/latest/download` tarball URL for the private smoke test.
