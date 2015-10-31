
# Mantis Bug Tracker
class Mantisbt < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('mantisbt/mantisbt', /release-([0-9\.]+)\z/i)
  end

  # @return [ String ]
  def release_download_url(repository, version)
    format('https://github.com/%s/archive/release-%s.zip', repository, version)
  end
end
