
# Mantis Bug Tracker
class Mantisbt < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('mantisbt/mantisbt', /release-([0-9\.]+)\.zip\z/i)
  end
end
