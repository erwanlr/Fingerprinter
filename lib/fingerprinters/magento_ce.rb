# frozen_string_literal: true

# Magento Community Edition
class MagentoCe < Fingerprinter
  include Experimental
  include GithubHosted
  include IgnorePattern::PHP

  def downloadable_versions
    github_releases('magento/magento2')
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # Deletes directories that can not be accessible due to .htaccess
    %w[app dev includes lib update phpserver shell var vendor].each do |dir|
      FileUtils.rm_rf(File.join(dest, dir), secure: true)
    end
  end
end
