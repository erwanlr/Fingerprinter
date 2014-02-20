
# WordPress
class Wordpress < Fingerprinter
  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('http://wordpress.org/download/release-archive/').body)

    page.css('.widefat').first.css('tbody tr td:first').each do |node|
      version = node.text.strip
      versions[version] = "http://wordpress.org/wordpress-#{version}.zip"
    end
    Hash[versions.to_a.reverse]
  end

  def archive_extension
    'zip'
  end

  def ignore_pattern
    /\A*.php\z/
  end
end
