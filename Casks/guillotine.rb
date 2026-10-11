# SPDX-License-Identifier: GPL-3.0-only
require_relative "../lib/guillotine_github_release_download_strategy"

cask "guillotine" do
  version "1.0.0"
  sha256 "e7ff885440c358865bdc33a18e055cf304808afa80614641face8e5abf7029ac"

  url "https://github.com/benjweaver/guillotine/releases/download/v#{version}/Guillotine-#{version}-macOS.zip",
      using: GuillotineGitHubReleaseDownloadStrategy
  name "Guillotine"
  desc "Turns off the built-in Mac screen and keyboard backlight for remote use"
  homepage "https://github.com/benjweaver/guillotine"

  depends_on formula: "gh"
  depends_on macos: ">= :ventura"

  app "Guillotine.app"

  # Pipe EOF releases the guard; the power helper independently expires its lease.
  uninstall signal: [["TERM", "dev.guillotine.Guillotine"]]

  # Never zap recovery journals: they may still own settings pending restoration.
  zap trash: "~/Library/Preferences/dev.guillotine.Guillotine.plist"

  caveats <<~EOS
    This tap and the app releases are private. Install gh and authenticate with
    an account that can read benjweaver/guillotine before installing or upgrading:
      gh auth login

    Physical panel control requires an Apple Silicon MacBook. Intel binaries
    are included, but do not support that control. Closed-lid operation and
    automatic Low Power Mode require explicit helper approval in Settings.

    Before upgrading, Restore in Guillotine. If a new version changes the helper,
    use Remove Helper and Install Helper in Settings afterward.
    Before uninstalling, Restore, Remove Helper, and disable launch at login.
    Recovery journals are deliberately retained, including during brew zap.
  EOS
end
