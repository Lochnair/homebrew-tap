# Linux GUI Casks Tap

Private Homebrew tap for proprietary/vendor GUI apps on Solus Linux without
Flatpak or Snap.

Primary target:

- Linux x86_64
- Solus Linux
- Homebrew installed at `/home/linuxbrew/.linuxbrew`

This tap uses official vendor artifacts only. It prefers upstream tarballs or
AppImages over extracting distro packages.

## Casks

- `1password-native`: official 1Password generic Linux tarball installed into
  `/opt/1Password`, with upstream `after-install.sh` run for native integration.
- `gitkraken`: official GitKraken Linux tarball installed into `/opt/gitkraken`.
- `zen-browser`: official Zen Browser GitHub release tarball installed into
  `/opt/zen-browser`.

## Install

From this repository path:

```sh
brew tap placeholder-user/linux-gui-casks /path/to/repo
brew install --cask 1password-native
brew install --cask gitkraken
brew install --cask zen-browser
```

Or use the example `Brewfile` after replacing `/path/to/repo`:

```sh
brew bundle --file Brewfile
```

These casks use `sudo` because they install native GUI app files under `/opt`,
`/usr/local/bin`, and `/usr/share/applications`.

## Usage

```sh
1password
gitkraken
zen
zen-browser
```

Desktop launchers are installed system-wide under `/usr/share/applications`.

## Test

```sh
brew audit --cask --new 1password-native gitkraken zen-browser
brew style
./scripts/verify-linux-desktop-apps.sh
```

For a private tap, Homebrew audit may report issues that are acceptable for this
Solus-only smoke test, especially `version :latest`, `sha256 :no_check`, Linux
desktop paths, and `sudo`-based `/opt` installs.

## Uninstall

```sh
brew uninstall --cask 1password-native
brew uninstall --cask gitkraken
brew uninstall --cask zen-browser
```

Normal uninstall removes only app install paths, generated symlinks, and desktop
files owned by these casks. It does not delete user vaults, browser profiles,
Git repositories, credentials, SSH configuration, or Git configuration.

## Zap

`zap` deletes user data. Run it only when you intentionally want local app data
removed:

```sh
brew zap --cask 1password-native
brew zap --cask gitkraken
brew zap --cask zen-browser
```

Review each cask's `zap` stanza before running these commands.

## Caveats

1Password is installed into `/opt/1Password` using the official generic Linux
tarball flow. The cask runs upstream `after-install.sh` because browser
integration, SSH agent integration, native messaging, and desktop launchers are
more important here than keeping all files inside the Homebrew prefix.

Browser integration for unsupported browsers may require adding the browser's
actual binary name to `/etc/1password/custom_allowed_browsers`. For Zen, install
Zen first and check the actual executable:

```sh
readlink -f "$(command -v zen)"
readlink -f "$(command -v zen-browser)"
ps -eo comm,args | grep -i '[z]en'
```

Then add the correct name only if the 1Password browser extension cannot
communicate with the desktop app.

1Password SSH agent and Git signing must be enabled/configured in 1Password and
in your own shell/Git configuration. This tap does not edit shell profiles,
system services, PAM, polkit, browser policy files, Git config, SSH config, or
vendor updater behavior.

## Manual Integration Checklist

1Password:

- App launches.
- App unlocks.
- `1password` is available, if expected by upstream's script.
- Desktop launcher appears.
- Browser extension can communicate with desktop app.
- SSH agent can be enabled in the app.
- `ssh-add -l` works when `SSH_AUTH_SOCK` points to the 1Password agent socket.
- Git commit signing with SSH works after user Git configuration.
- Reboot does not break integration.

Zen:

- Browser launches with `zen`.
- Browser launches with `zen-browser`.
- Browser launches from the desktop entry.
- Default browser integration can be configured manually.
- 1Password browser extension works after adding the correct browser binary name
  to `/etc/1password/custom_allowed_browsers`, if needed.

GitKraken:

- App launches with `gitkraken`.
- App launches from the desktop entry.
- It can find system Git or bundled Git as expected.
- It can use the 1Password SSH agent once 1Password is configured.
- Push/pull over SSH works in a test repository.

## Research Sources

- Homebrew Cask Cookbook: https://docs.brew.sh/Cask-Cookbook
- Homebrew 4.5.0 release notes for Linux casks:
  https://brew.sh/2025/04/29/homebrew-4.5.0/
- Homebrew 5.0.0 release notes for improved Linux cask usability:
  https://brew.sh/2025/11/12/homebrew-5.0.0/
- 1Password Linux install docs:
  https://support.1password.com/install-linux/
- GitKraken Linux install docs:
  https://help.gitkraken.com/gitkraken-desktop/how-to-install/
- Zen Browser Linux install docs:
  https://docs.zen-browser.app/guides/install-linux

## Exact Solus Test Commands

Replace `/home/lochnair/Work/brew-tap` if the repository is elsewhere:

```sh
brew tap placeholder-user/linux-gui-casks /home/lochnair/Work/brew-tap
brew install --cask 1password-native
brew install --cask gitkraken
brew install --cask zen-browser
brew audit --cask --new 1password-native gitkraken zen-browser
brew style
./scripts/verify-linux-desktop-apps.sh
brew uninstall --cask zen-browser
brew uninstall --cask gitkraken
brew uninstall --cask 1password-native
```

User-data deleting commands, only when intentionally wiping local app data:

```sh
brew zap --cask zen-browser
brew zap --cask gitkraken
brew zap --cask 1password-native
```
