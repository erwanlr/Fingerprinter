# frozen_string_literal: true

# Apache Icons
class ApacheIcons < Fingerprinter
  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get('http://archive.apache.org/dist/httpd/').body)

    page.css('a').each do |link|
      version = link.text.strip[/^(?:apache_|httpd-)([0-9.]+)\.tar\.gz$/, 1]

      if version
        prefix = version >= '2.0' ? 'httpd-' : 'apache_'
        versions[version] = "http://archive.apache.org/dist/httpd/#{prefix}#{version}.tar.gz"
      end
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)
    # Apache >= 2.0 uses docs/icons, < 2.0 uses icons
    [File.join(dest, 'docs', 'icons'), File.join(dest, 'icons')].each do |icon_dir|
      rebase(icon_dir, dest) if Dir.exist?(icon_dir)
    end
  end
end
