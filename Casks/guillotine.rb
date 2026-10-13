# SPDX-License-Identifier: GPL-3.0-only
cask "guillotine" do
  version "1.0.3"
  sha256 "48193f49da70bf087e1b10f26cfa24398acd0636f8b93974695182e3ac1d7ad6"

  url "https://github.com/benjweaver/guillotine/releases/download/v#{version}/Guillotine-#{version}-macOS.zip"
  name "Guillotine"
  desc "Turns off the built-in screen and keyboard backlight for remote use"
  homepage "https://github.com/benjweaver/guillotine"

  depends_on macos: :ventura

  app "Guillotine.app"

  # Pipe EOF releases the guard; the power helper independently expires its lease.
  uninstall signal: [["TERM", "dev.guillotine.Guillotine"]]

  # Never zap recovery journals: they may still own settings pending restoration.
  zap trash: "~/Library/Preferences/dev.guillotine.Guillotine.plist"

  caveats <<~EOS
    Physical panel control requires an Apple Silicon MacBook. Intel binaries
    are included, but do not support that control. Closed-lid operation and
    automatic Low Power Mode require explicit helper approval in Settings.

    Before upgrading, Restore in Guillotine. If a new version changes the helper,
    use Remove Helper and Install Helper in Settings afterward.
    Before uninstalling, Restore, Remove Helper, and disable launch at login.
    Recovery journals are deliberately retained, including during brew zap.
  EOS
end
