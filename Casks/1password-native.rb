cask "1password-native" do
  version :latest
  sha256 :no_check

  url "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz"
  name "1Password Native"
  desc "Password manager with native Linux desktop integration"
  homepage "https://1password.com/downloads/linux/"

  depends_on arch: :x86_64

  stage_only true

  postflight do
    install_script = <<~EOS
      set -euo pipefail

      staged_path="$1"
      source_dir="$(find "$staged_path" -mindepth 1 -maxdepth 1 -type d -name '1password-*' | head -n 1)"

      if [ -z "$source_dir" ]; then
        echo "Could not find extracted 1Password directory in $staged_path" >&2
        exit 1
      fi

      if [ ! -x "$source_dir/after-install.sh" ]; then
        echo "Missing executable after-install.sh in $source_dir" >&2
        exit 1
      fi

      rm -rf /opt/1Password.tmp
      mkdir -p /opt/1Password.tmp
      cp -a "$source_dir"/. /opt/1Password.tmp/
      rm -rf /opt/1Password
      mv /opt/1Password.tmp /opt/1Password
      /opt/1Password/after-install.sh
    EOS

    system_command "/usr/bin/sudo",
                   args: [
                     "/bin/bash", "-c", install_script,
                     "--", staged_path.to_s
                   ]
  end

  uninstall_preflight do
    cleanup_script = <<~EOS
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
            /opt/1Password/*) rm -f "$path" ;;
          esac
        elif [ -f "$path" ] && grep -F "/opt/1Password" "$path" >/dev/null 2>&1; then
          rm -f "$path"
        fi
      done
    EOS

    system_command "/usr/bin/sudo",
                   args: ["/bin/bash", "-c", cleanup_script]
  end

  uninstall delete: "/opt/1Password"

  zap trash: [
    "~/.cache/1Password",
    "~/.config/1Password BrowserSupport",
    "~/.config/1Password",
    "~/.local/share/1Password",
  ]

  caveats <<~EOS
    1Password is installed into /opt/1Password using the official generic Linux
    tarball layout and upstream after-install.sh script.

    This cask requires sudo because upstream's native integration installs files
    outside the Homebrew prefix.

    Browser integration for unsupported browsers may require adding the browser's
    actual binary name to:
      /etc/1password/custom_allowed_browsers

    For Zen Browser, install Zen first, confirm the executable name with:
      readlink -f "$(command -v zen)"
      readlink -f "$(command -v zen-browser)"

    Then add the correct browser binary name only if 1Password's browser
    integration requires it.

    1Password SSH agent and Git commit signing must be enabled and configured in
    the 1Password app and in your own shell/Git configuration.
  EOS
end
