# frozen_string_literal: true

# os Commerce 2
class OsCommerce2 < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('osCommerce/oscommerce2')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'catalog'), dest)
  end
end
