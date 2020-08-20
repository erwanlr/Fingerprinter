# frozen_string_literal: true

# LifeRay (http://sourceforge.net/projects/lportal/ & https://www.liferay.com/)
class Liferay < Fingerprinter
  include GithubHosted

  def downloadable_versions
    versions = {}

    github_releases(
      'liferay/liferay-portal',
      %r{/download/(?<v>[\d\.]+\-GA\d+)/liferay\-ce\-portal\-tomcat\-[\d\.]+\-ga\d+\-\d+.(?:tar.gz|zip|7z)}i
    ) do |version, download_url|
      versions[version.upcase] = download_url
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    Dir[File.join(dest, '**/')].each do |entry|
      [%r{webapps\/ROOT}i, /liferay\-portal\.war/, /ROOT\.war/i].each do |pattern|
        return rebase(entry, dest) if entry =~ pattern
      end
    end

    # Some versions (i.e <= 4.3.0 have a different web folder and have to be added manually)
    raise "Unable to locate web folder in #{dest}"
  end

  def ignore_pattern
    %r{\A(.*(web\-inf|ckeditor/plugins).*|.*.(jspf?|jar|class|war|xsd|dtd))\z}i
  end
end
