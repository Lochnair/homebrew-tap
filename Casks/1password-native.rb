cask "1password-native" do
  version :latest
  sha256 :no_check

  url "https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz",
      verified: "downloads.1password.com/linux/tar/"
  name "1Password"
  desc "Password manager"
  homepage "https://1password.com/downloads/linux/"

  depends_on arch: :x86_64

  stage_only true

  postflight do
    system_command "/bin/bash",
                   args: [
                     "-c",
                     <<~EOS,
                       set -euo pipefail

                       source_dir="$(
                         find "#{staged_path}" \\
                           -mindepth 1 \\
                           -maxdepth 1 \\
                           -type d \\
                           -name '1password-*' \\
                           | sort \\
                           | head -n 1
                       )"

                       if [ -z "$source_dir" ]; then
                         echo "Could not find extracted 1Password directory in #{staged_path}" >&2
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
                   ],
                   sudo: true,
                   print_stdout: true,
                   print_stderr: true
  end

  uninstall_preflight do
    system_command "/bin/bash",
                   args: [
                     "-c",
                     <<~EOS,
                       set -euo pipefail

                       rm -rf /opt/1Password

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
                           rm -f "$path"
                         elif [ -f "$path" ] && grep -F "/opt/1Password" "$path" >/dev/null 2>&1; then
                           rm -f "$path"
                         fi
                       done
                     EOS
                   ],
                   sudo: true,
                   print_stdout: true,
                   print_stderr: true
  end

  zap trash: [
    "~/.cache/1Password",
    "~/.config/1Password",
    "~/.config/1Password BrowserSupport",
    "~/.local/share/1Password",
  ]

  caveats <<~EOS
    1Password is installed into:

      /opt/1Password

    This cask follows 1Password's generic Linux tarball install flow.

    If sudo prompting fails, run:

      sudo -v
      brew install --cask 1password-native

    Do not run:

      sudo brew install --cask 1password-native

    Browser integration for unsupported browsers may require adding the browser's
    actual binary name to:

      /etc/1password/custom_allowed_browsers
  EOS
end