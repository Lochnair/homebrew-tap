cask "zen-browser" do
  version :latest
  sha256 :no_check

  url "https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz",
      verified: "github.com/zen-browser/desktop/"
  name "Zen Browser"
  desc "Firefox-based web browser"
  homepage "https://zen-browser.app/"

  depends_on arch: :x86_64

  postflight do
    install_script = <<~EOS
      set -euo pipefail

      staged_path="$1"
      source_file="$(find "$staged_path" -mindepth 1 -maxdepth 2 -type f -name zen -perm -111 -print -quit)"

      if [ -z "$source_file" ]; then
        echo "Could not find Zen executable in $staged_path" >&2
        exit 1
      fi

      source_dir="$(dirname "$source_file")"

      rm -rf /opt/zen-browser.tmp
      mkdir -p /opt/zen-browser.tmp
      cp -a "$source_dir"/. /opt/zen-browser.tmp/
      rm -rf /opt/zen-browser
      mv /opt/zen-browser.tmp /opt/zen-browser

      ln -sfn /opt/zen-browser/zen /usr/local/bin/zen
      ln -sfn /opt/zen-browser/zen /usr/local/bin/zen-browser

      mkdir -p /usr/share/applications
      icon_path="/opt/zen-browser/browser/chrome/icons/default/default128.png"

      if [ ! -f "$icon_path" ]; then
        echo "Missing Zen icon at $icon_path" >&2
        exit 1
      fi

      printf '%s\\n' \\
        '[Desktop Entry]' \\
        'Name=Zen Browser' \\
        'Comment=Firefox-based web browser' \\
        'Exec=/opt/zen-browser/zen %u' \\
        'Terminal=false' \\
        'Type=Application' \\
        "Icon=$icon_path" \\
        'StartupWMClass=zen' \\
        'Categories=Network;WebBrowser;' \\
        'MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;' \\
        > /usr/share/applications/zen-browser.desktop
    EOS

    system_command "/usr/bin/sudo",
                   args: [
                     "/bin/bash", "-c", install_script,
                     "--", staged_path.to_s
                   ]
  end

  uninstall delete: [
    "/opt/zen-browser",
    "/usr/local/bin/zen",
    "/usr/local/bin/zen-browser",
    "/usr/share/applications/zen-browser.desktop",
  ]

  zap trash: [
    "~/.cache/zen",
    "~/.zen",
  ]

  caveats <<~EOS
    Zen Browser is installed into /opt/zen-browser from the official GitHub
    release tarball. The upstream executable is named zen; this cask links both
    zen and zen-browser into /usr/local/bin.

    This cask intentionally does not edit /etc/1password/custom_allowed_browsers.
    To integrate Zen with 1Password, first check the actual browser process or
    binary name after installation:
      readlink -f "$(command -v zen)"
      ps -eo comm,args | grep -i '[z]en'

    If the 1Password browser extension cannot communicate with the desktop app,
    add the correct Zen binary name to /etc/1password/custom_allowed_browsers.
  EOS
end
