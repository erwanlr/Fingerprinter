# frozen_string_literal: true

# Joomla!
class Joomla < Fingerprinter
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    # The v3 seems to be an error in the release version name
    # As the OEF of the v3.x was in May 2013 and this v3 was released in July 2014
    # See https://github.com/joomla/joomla-cms/releases?after=2.5.27
    github_releases('joomla/joomla-cms').merge(old_versions).delete_if { |k, _| k == '3' }
  end

  # @return [ Hash ] The versions not available on the github repo (i.e from 1.5 and below branchs)
  def old_versions
    JSON.parse(File.read(File.join(DB_DIR, 'joomla_old_versions.json')))
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # Delete Dev folders
    %w[build tests].each do |dir|
      FileUtils.rm_rf(File.join(dest, dir), secure: true)
    end

    # Delete Dev files
    %w[build.xml composer.json composer.lock CONTRIBUTING.md phpunit.xml.dist travisci-phpunit.xml].each do |file|
      FileUtils.rm_f(File.join(dest, file))
    end
  end
end
