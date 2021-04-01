# frozen_string_literal: true

# CKEditor
class Ckeditor < Fingerprinter
  include GithubHosted

  def downloadable_versions
    github_releases('ckeditor/ckeditor4-releases')
  end
end
