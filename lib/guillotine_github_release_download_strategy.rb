# SPDX-License-Identifier: GPL-3.0-only
require "download_strategy"

# Let gh use its own credential store; never put a token in a URL or curl argument.
class GuillotineGitHubReleaseDownloadStrategy < AbstractFileDownloadStrategy
  def fetch(timeout: nil)
    match = %r{\Ahttps://github\.com/(benjweaver/guillotine)/releases/download/(v\d+\.\d+\.\d+)/(Guillotine-\d+\.\d+\.\d+-macOS\.zip)\z}.match(url)
    raise "Unsupported Guillotine release URL" unless match

    gh = HOMEBREW_PREFIX/"bin/gh"
    raise "Install gh and run gh auth login before downloading this private release" unless gh.executable?

    lock = DownloadLock.new(temporary_path)
    begin
      lock.lock_or_wait(quiet: quiet?, timeout: timeout)
      unless cached_location.exist?
        temporary_path.dirname.mkpath
        system_command! gh, args: ["release", "download", match[2], "--repo", match[1],
                                  "--pattern", match[3], "--output", temporary_path.to_s, "--clobber"],
                            env: { "GH_HOST" => "github.com" }, timeout: timeout
        temporary_path.rename(cached_location)
      end
      create_symlink_to_cached_download(cached_location)
    ensure
      lock.unlock(unlink: true)
    end
  end
end
