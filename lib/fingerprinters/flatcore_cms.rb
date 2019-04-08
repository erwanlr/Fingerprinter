# frozen_string_literal: true

# Flatcore CMS
class FlatcoreCms < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('flatCore/flatCore-CMS')
  end
end
