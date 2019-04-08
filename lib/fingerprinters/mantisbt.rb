# frozen_string_literal: true

# Mantis Bug Tracker
class Mantisbt < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('mantisbt/mantisbt', /release-(?<v>[0-9\.]+)\.zip\z/i)
  end
end
