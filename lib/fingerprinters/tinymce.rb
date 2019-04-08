# frozen_string_literal: true

# Tiny MCE
class Tinymce < Fingerprinter
  include GithubHosted

  def downloadable_versions
    github_releases('tinymce/tinymce')
  end
end
