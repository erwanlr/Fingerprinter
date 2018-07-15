
# WordPress
class Wordpress < Fingerprinter
  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://wordpress.org/download/releases/').body)

    page.css('table.releases tr td:first').each do |node|
      version = node.text.strip

      next unless version =~ /\A[\d\.]+\z/

      versions[version] = "http://wordpress.org/wordpress-#{version}.zip"
    end

    versions
  end

  def ignore_pattern
    %r{\A*(wp\-content/(plugins|themes).*|.php)\z}i
  end
end
