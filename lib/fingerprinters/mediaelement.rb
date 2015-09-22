
# Media Element
class Mediaelement < Fingerprinter
  include GithubHosted
  include Experimental

  def downloadable_versions
    github_releases('johndyer/mediaelement')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'build'), dest)
  end
end
