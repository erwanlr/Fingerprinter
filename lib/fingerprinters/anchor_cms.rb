# frozen_string_literal: true

# Anchor CMS
class AnchorCms < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('anchorcms/anchor-cms')
  end
end
