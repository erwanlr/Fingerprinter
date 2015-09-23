
# Joomla!
class Joomla < Fingerprinter
  include GithubHosted
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('joomla/joomla-cms')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # Delete Dev folders
    %w(build tests).each do |dir|
      FileUtils.rm_rf(File.join(dest, dir), secure: true)
    end

    # Delete Dev files
    %w(build.xml composer.json composer.lock CONTRIBUTING.md phpunit.xml.dist travisci-phpunit.xml).each do |file|
      FileUtils.rm_f(File.join(dest, file))
    end
  end
end
