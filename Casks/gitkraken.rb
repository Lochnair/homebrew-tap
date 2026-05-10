cask "gitkraken" do
  version :latest
  sha256 :no_check

  url "https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz",
      verified: "release.gitkraken.com/linux/"
  name "GitKraken Desktop"
  desc "Graphical Git client"
  homepage "https://www.gitkraken.com/download"

  depends_on arch: :x86_64

  stage_only true

  postflight do
    install_script = <<~EOS
      set -euo pipefail

      staged_path="$1"
      source_file="$(find "$staged_path" -mindepth 1 -maxdepth 2 -type f -name gitkraken -perm -111 -print -quit)"

      if [ -z "$source_file" ]; then
        echo "Could not find GitKraken executable in $staged_path" >&2
        exit 1
      fi

      source_dir="$(dirname "$source_file")"

      rm -rf /opt/gitkraken.tmp
      mkdir -p /opt/gitkraken.tmp
      cp -a "$source_dir"/. /opt/gitkraken.tmp/
      rm -rf /opt/gitkraken
      mv /opt/gitkraken.tmp /opt/gitkraken

      ln -sfn /opt/gitkraken/gitkraken /usr/local/bin/gitkraken
      mkdir -p /usr/share/applications

      icon_path="/opt/gitkraken/gitkraken.png"
      if [ ! -f "$icon_path" ]; then
        icon_path="/opt/gitkraken/resources/app.asar.unpacked/src/images/icons/icon.png"
      fi

      printf '%s\\n' \\
        '[Desktop Entry]' \\
        'Name=GitKraken' \\
        'Comment=Graphical Git client' \\
        'Exec=/opt/gitkraken/gitkraken %U' \\
        'Terminal=false' \\
        'Type=Application' \\
        "Icon=$icon_path" \\
        'StartupWMClass=gitkraken' \\
        'Categories=Development;RevisionControl;' \\
        'MimeType=x-scheme-handler/gitkraken;' \\
        > /usr/share/applications/gitkraken.desktop
    EOS

    system_command "/usr/bin/sudo",
                   args: [
                     "/bin/bash", "-c", install_script,
                     "--", staged_path.to_s
                   ]
  end

  uninstall delete: [
    "/opt/gitkraken",
    "/usr/local/bin/gitkraken",
    "/usr/share/applications/gitkraken.desktop",
  ]

  zap trash: [
    "~/.config/GitKraken",
    "~/.gitkraken",
  ]

  caveats <<~EOS
    GitKraken is installed into /opt/gitkraken from the official Linux tarball.
    A system desktop entry is generated at /usr/share/applications/gitkraken.desktop
    and gitkraken is linked into /usr/local/bin.

    This cask does not configure Git repositories, remotes, SSH keys, credentials,
    or GitKraken accounts.
  EOS
end
