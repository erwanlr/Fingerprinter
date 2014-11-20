
# WordPress
class Wordpress < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://wordpress.org/download/release-archive/').body)

    page.css('.widefat').first.css('tbody tr td:first').each do |node|
      version = node.text.strip
      versions[version] = "http://wordpress.org/wordpress-#{version}.zip"
    end

    versions
  end
end
