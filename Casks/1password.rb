cask "1password" do
  arch arm: "aarch64", intel: "x86_64"

  version "8.12.12"

  name "1Password"
  desc "Password manager that keeps all passwords secure behind one password"
  homepage "https://1password.com/"

  livecheck do
    url "https://app-updates.agilebits.com/check/2/99/#{arch}/OPM#{version.major}/en/0/A1/N"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  conflicts_with cask: [
    "1password@beta",
    "1password@nightly",
  ]

  on_macos do
    sha256 arm:   "22a330e1d80c8479338cc55b999cbf877962ef8259c5b63c0f808e78c120fb5a",
           intel: "eaf54c92b6bb4f891546b567f107b104c4641c3ad4a195cffde00bc813d83e8c"

    url "https://downloads.1password.com/mac/1Password-#{version}-#{arch}.zip"

    depends_on macos: ">= :monterey"

    app "1Password.app"

    zap trash: [
      "~/Library/Application Scripts/2BUA8C4S2C.com.1password*",
      "~/Library/Application Scripts/2BUA8C4S2C.com.agilebits",
      "~/Library/Application Scripts/com.1password.1password-launcher",
      "~/Library/Application Scripts/com.1password.browser-support",
      "~/Library/Application Support/1Password",
      "~/Library/Application Support/Arc/User Data/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.1password.1password.sfl*",
      "~/Library/Application Support/CrashReporter/1Password*",
      "~/Library/Application Support/Google/Chrome Beta/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Google/Chrome Canary/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Google/Chrome Dev/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Microsoft Edge Beta/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Microsoft Edge Canary/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Microsoft Edge Dev/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Microsoft Edge/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Mozilla/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Application Support/Vivaldi/NativeMessagingHosts/com.1password.1password.json",
      "~/Library/Containers/2BUA8C4S2C.com.1password.browser-helper",
      "~/Library/Containers/com.1password.1password*",
      "~/Library/Containers/com.1password.browser-support",
      "~/Library/Group Containers/2BUA8C4S2C.com.1password",
      "~/Library/Group Containers/2BUA8C4S2C.com.agilebits",
      "~/Library/Logs/1Password",
      "~/Library/Preferences/com.1password.1password.plist",
      "~/Library/Preferences/group.com.1password.plist",
      "~/Library/Saved Application State/com.1password.1password.savedState",
    ]
  end

  on_linux do
    linux_arch = Hardware::CPU.arm? ? "arm64" : "x64"

    sha256  arm64_linux:  "44dc193aaaf6f5a2e0349607ffae931442822b701506193eaa749ac7e63b0e5e",
            x86_64_linux: "b5d86e0497825db7a90cde99f58aacea013994c521ef6b0e26e412bf84288f53"

    url "https://downloads.1password.com/linux/tar/stable/#{arch}/1password-#{version}.#{linux_arch}.tar.gz",
        verified: "downloads.1password.com/linux/tar/stable/"

    installer script: {
      executable: "/bin/bash",
      args:       [
        "-c",
        <<~EOS,
          set -euo pipefail

          staged_path="$1"
          source_dir="$staged_path/1password-#{version}.#{linux_arch}"
          install_root="/opt/1Password"
          tmp_root="/opt/1Password.tmp.$$"

          if [ ! -d "$source_dir" ]; then
            echo "Missing staged 1Password directory: $source_dir" >&2
            exit 1
          fi

          if [ ! -x "$source_dir/after-install.sh" ]; then
            echo "Missing executable after-install.sh in: $source_dir" >&2
            exit 1
          fi

          rm -rf "$tmp_root"
          mkdir -p "$tmp_root"
          cp -a "$source_dir"/. "$tmp_root"/

          rm -rf "$install_root"
          mv "$tmp_root" "$install_root"

          "$install_root/after-install.sh"
        EOS
        "1password-linux-install",
        staged_path.to_s,
      ],
      sudo:         true,
      print_stderr: true,
      print_stdout: true,
    }

    uninstall script: {
      executable: "/bin/bash",
      args:       [
        "-c",
        <<~EOS,
          set -euo pipefail

          install_root="/opt/1Password"

          if [ -x "$install_root/after-remove.sh" ]; then
            "$install_root/after-remove.sh"
          fi

          if [ -d "$install_root" ] && [ -e "$install_root/1password" ]; then
            rm -rf "$install_root"
          fi
        EOS
        "1password-linux-uninstall",
      ],
      sudo:         true,
      print_stderr: true,
      print_stdout: true,
    }

    zap trash: [
      "~/.cache/1Password",
      "~/.config/1Password",
      "~/.config/1Password BrowserSupport",
      "~/.local/share/1Password",
    ]
  end
end
