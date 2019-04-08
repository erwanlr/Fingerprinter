# frozen_string_literal: true

# Django CMS
class DjangoCms < Fingerprinter
  include GithubHosted

  def downloadable_versions
    github_releases('divio/django-cms')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'cms'), dest)
  end

  def ignore_pattern
    /\A*.(py|pyc|html|po|mo)\z/i
  end
end
