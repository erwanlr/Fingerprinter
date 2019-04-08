# frozen_string_literal: true

# Moodle
class Moodle < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('moodle/moodle')
  end
end
