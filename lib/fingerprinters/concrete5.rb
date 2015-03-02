
# Concrete5
class Concrete5 < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get('http://www.concrete5.org/developers/developer-downloads/').body)

    page.css('div#body-content p a').each do |node|
      version = node.parent.text.strip[/\A([0-9\.]+)\s*\(/i, 1]
      dl_path = node['href'].strip

      versions[version] = "http://www.concrete5.org#{dl_path}"
    end

    versions
  end

  protected

  # The Extension is not in the url, so we force it
  # Otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end
end
