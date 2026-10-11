# Homebrew tap for Guillotine

[Guillotine](https://github.com/benjweaver/guillotine) turns off the built-in
Apple Silicon MacBook screen and keyboard backlight for remote use. The app is
signed with Developer ID, notarized, and licensed GPL-3.0-only.

```sh
brew install --cask benjweaver/guillotine/guillotine
```

Update with `brew upgrade --cask benjweaver/guillotine/guillotine`.

Before upgrading, Restore in Guillotine. Reload the helper in Settings if the
release changes it. Before uninstalling, Restore, Remove Helper, and disable
launch at login. Homebrew sends TERM to the app; its guard and power helper
release leases independently. Recovery journals are retained even with zap.

`scripts/update-cask.sh vX.Y.Z` downloads the notarized archive and published
checksums, verifies them, and updates the cask. Guillotine's release script
runs it and pushes the tap after publishing a release. No scheduled polling.

The standard release URL requires public repository/release visibility for
unauthenticated installation. Ben controls when the repositories become public.

Local checks:

```sh
brew style benjweaver/guillotine/guillotine
brew fetch --cask benjweaver/guillotine/guillotine
shellcheck scripts/update-cask.sh
```
