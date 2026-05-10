cask "1password" do
  arch arm: "aarch64", intel: "x86_64"

  on_macos do
    version "8.12.12"
    sha256 arm:   "22a330e1d80c8479338cc55b999cbf877962ef8259c5b63c0f808e78c120fb5a",
           intel: "eaf54c92b6bb4f891546b567f107b104c4641c3ad4a195cffde00bc813d83e8c"

    url "https://downloads.1password.com/mac/1Password-#{version}-#{arch}.zip"

    livecheck do
      url "https://app-updates.agilebits.com/check/2/99/#{arch}/OPM#{version.major}/en/0/A1/N"
      strategy :json do |json|
        json["version"]
      end
    end

    depends_on macos: ">= :monterey"

    app "1Password.app"
  end

  on_linux do
    version :latest
    sha256 :no_check

    url "https://downloads.1password.com/linux/tar/stable/#{arch}/1password-latest.tar.gz",
        verified: "downloads.1password.com/linux/tar/"

    # Upstream extracts to something like `1password-*`, which is not stable
    # enough to reference directly.
    rename "1password-*", "1Password"

    # 1Password's official generic Linux install target is /opt/1Password.
    artifact "1Password", target: "/opt/1Password"

    postflight do
      system_command "/opt/1Password/after-install.sh",
                     sudo: true,
                     print_stderr: true,
                     print_stdout: true
    end


    uninstall_preflight do
      after_remove = "/opt/1Password/after-remove.sh"

      if File.executable?(after_remove)
        system_command after_remove,
                     sudo: true,
                     print_stderr: true,
                     print_stdout: true
      end
    end

    zap trash: [
      "~/.cache/1Password",
      "~/.config/1Password",
      "~/.config/1Password BrowserSupport",
      "~/.local/share/1Password",
    ]
  end

  name "1Password"
  desc "Password manager that keeps all passwords secure behind one password"
  homepage "https://1password.com/"

  auto_updates true
  conflicts_with cask: [
    "1password@beta",
    "1password@nightly",
  ]

  on_macos do
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
end