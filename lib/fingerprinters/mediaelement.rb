# frozen_string_literal: true

# Media Element
class Mediaelement < Fingerprinter
  include GithubHosted
  include Experimental

  def downloadable_versions
    # versions below 1.0.4 are deleted as they do not contain the JS files
    github_releases('mediaelement/mediaelement').delete_if do |key, _|
      %w[1.0.3 1.0.2 1.0.1 1.0.0].include?(key)
    end
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'build'), dest)
  end
end
