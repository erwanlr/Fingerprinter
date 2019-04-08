# frozen_string_literal: true

# Open Cart
class OpenCart < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    old_versions.merge(github_releases('opencart/opencart'))
  end

  def old_versions
    {
      '1.5.4.1' => old_download_url(29),
      '1.5.4' => old_download_url(28)
    }
  end

  def old_download_url(id)
    format('http://www.opencart.com/index.php?route=download/download/download&download_id=%i', id)
  end

  # The Extension is not in the url for the old_versions,
  # so we force it, otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'upload'), dest)
  end
end
