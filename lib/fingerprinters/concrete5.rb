# frozen_string_literal: true

# Concrete5
class Concrete5 < Fingerprinter
  include IgnorePattern::PHP

  def download_page_uri
    @download_page_uri ||= Addressable::URI.parse('https://www.concrete5.org/developers/developer-downloads/')
  end

  def downloadable_versions
    versions = legacy_versions

    # Adds the latest version (from the get started page)
    node = Nokogiri::HTML(Typhoeus.get('https://www.concrete5.org/download').body).css('div.col-sm-12 p a').first

    version = node.text.strip[/Download ([0-9\.]+)\z/i, 1]
    dl_path = node['href'].strip

    versions[version] = download_page_uri.join(dl_path).to_s if version

    versions
  end

  def legacy_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(download_page_uri.to_s).body)

    page.css('div#body-content p a').each do |node|
      version = node.parent.text.strip[/\A([0-9\.]+)\s*\(/i, 1]
      dl_path = node['href'].strip

      next unless version

      versions[version] = download_page_uri.join(dl_path).to_s
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
