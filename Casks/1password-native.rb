cask "1password-native" do
  version :latest
  sha256 :no_check

  url "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz"
  name "1Password"
  desc "Password manager with native Linux desktop integration"
  homepage "https://1password.com/downloads/linux/"

  depends_on arch: :x86_64

  installer script: {
    executable:   "/bin/bash",
    args:         [
      "-c",
      <<~EOS,
        set -euo pipefail

        staged_path="$1"

        source_dir="$(
          find "$staged_path" \\
            -mindepth 1 \\
            -maxdepth 1 \\
            -type d \\
            -name '1password-*' \\
            | sort \\
            | head -n 1
        )"

        if [ -z "$source_dir" ]; then
          echo "Could not find extracted 1Password directory in: $staged_path" >&2
          exit 1
        fi

        if [ ! -x "$source_dir/after-install.sh" ]; then
          echo "Missing executable after-install.sh in: $source_dir" >&2
          exit 1
        fi

        install_root="/opt/1Password"
        tmp_root="/opt/1Password.tmp.$$"
        backup_root="/opt/1Password.previous.$$"

        rm -rf "$tmp_root"
        mkdir -p "$tmp_root"

        cp -a "$source_dir"/. "$tmp_root"/

        if [ -e "$install_root" ]; then
          mv "$install_root" "$backup_root"
        fi

        mv "$tmp_root" "$install_root"

        if ! "$install_root/after-install.sh"; then
          rm -rf "$install_root"
          if [ -e "$backup_root" ]; then
            mv "$backup_root" "$install_root"
          fi
          exit 1
        fi

        rm -rf "$backup_root"
      EOS
      "1password-native-installer",
      staged_path.to_s,
    ],
    sudo:         true,
    print_stdout: true,
    print_stderr: true,
  }

  uninstall script: {
    executable:   "/bin/bash",
    args:         [
      "-c",
      <<~EOS,
        set -euo pipefail

        for path in \\
          /usr/bin/1password \\
          /usr/share/applications/1password.desktop \\
          /usr/share/icons/hicolor/512x512/apps/1password.png \\
          /usr/share/icons/hicolor/256x256/apps/1password.png \\
          /usr/share/icons/hicolor/128x128/apps/1password.png \\
          /usr/share/icons/hicolor/64x64/apps/1password.png \\
          /usr/share/icons/hicolor/32x32/apps/1password.png \\
          /usr/share/icons/hicolor/16x16/apps/1password.png
        do
          if [ -L "$path" ]; then
            target="$(readlink "$path")"
            case "$target" in
              /opt/1Password/*)
                rm -f "$path"
                ;;
            esac
          elif [ -f "$path" ] && grep -F "/opt/1Password" "$path" >/dev/null 2>&1; then
            rm -f "$path"
          fi
        done

        rm -rf /opt/1Password
      EOS
      "1password-native-uninstaller",
    ],
    sudo:         true,
    print_stdout: true,
    print_stderr: true,
  }

  zap trash: [
    "~/.cache/1Password",
    "~/.config/1Password BrowserSupport",
    "~/.config/1Password",
    "~/.local/share/1Password",
  ]

  caveats <<~EOS
    1Password is installed into:

      /opt/1Password

    This cask uses the official generic Linux tarball layout and runs
    upstream's after-install.sh.

    This cask requires sudo because native 1Password integration installs files
    outside the Homebrew prefix.

    Do not run this with sudo brew. If sudo prompting fails, run:

      sudo -v
      brew install --cask 1password-native

    Browser integration for unsupported browsers may require adding the browser's
    actual binary name to:

      /etc/1password/custom_allowed_browsers

    For Zen Browser, install Zen first, then check the real executable name with:

      command -v zen
      command -v zen-browser
      readlink -f "$(command -v zen 2>/dev/null || true)"
      readlink -f "$(command -v zen-browser 2>/dev/null || true)"

    1Password SSH agent and Git commit signing must still be enabled/configured
    in the 1Password app and your own SSH/Git configuration.
  EOS
end
