# frozen_string_literal: true

# Bolt CMS
class Bolt < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('bolt/bolt', %r{/download/v?(?<v>[\d.]+)/bolt-v?[\d.]+\.zip}i)
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'public'), dest) if Pathname.new(dest).join('public').directory?
  end
end
