# frozen_string_literal: true

# Big Tree CMS
class BigTreeCms < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('bigtreecms/BigTree-CMS')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'core'), dest)
  end
end
