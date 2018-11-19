# Drupal
class Drupal < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(release_url).body)

    page.xpath('//a[starts-with(@href, "drupal-")]/@href').each do |node|
      version = node.text.strip[/\Adrupal\-([\d\.]+)\.tar\.gz\z/i, 1]

      versions[version] = "#{release_url}#{node.text.strip}" if version
    end

    versions
  end

  def release_url
    @release_url ||= 'https://ftp.drupal.org/files/projects/'
  end
end
