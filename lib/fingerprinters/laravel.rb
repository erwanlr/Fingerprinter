# frozen_string_literal: true

# Laravel
class Laravel < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('laravel/laravel')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'public'), dest)
  end
end
