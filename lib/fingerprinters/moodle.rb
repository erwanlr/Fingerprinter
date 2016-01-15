
# Moodle
class Moodle < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('moodle/moodle', /v([0-9\.]+)\z/i)
  end

  # @return [ String ]
  def release_download_url(repository, version)
    format('https://github.com/%s/archive/v%s.zip', repository, version)
  end
end
