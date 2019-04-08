# frozen_string_literal: true

# RoundCubeMail
class Roundcubemail < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('roundcube/roundcubemail')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # Delete tests folder
    FileUtils.rm_rf(File.join(dest, 'tests'), secure: true)
  end
end
