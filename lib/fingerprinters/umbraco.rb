
# Umbraco
class Umbraco < Fingerprinter
  include Experimental
  include IgnorePattern::ASP

  def downloadable_versions
    historical_versions.merge(current_versions)
  end

  def site_url
    'http://our.umbraco.org'
  end

  def current_versions
    versions = {}
    json     = JSON.parse(Typhoeus.get("#{site_url}/api/GetAllFromFile/").body)

    json.each do |obj|
      if obj['currentRelease']
        version           = obj['version']
        versions[version] = download_link("#{site_url}/contribute/releases/#{version.delete('.')}/")
      end
    end

    versions
  end

  def historical_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get("#{site_url}/download").body)

    page.css('div.version h2 a').each do |node|
      version = node.text.strip

      if version =~ /\A[0-9\.]+\z/
        versions[version] = download_link("#{site_url}#{node.attr('href')}")
      end
    end

    versions
  end

  protected

  def download_link(url)
    href = Nokogiri::HTML(Typhoeus.get(url).body).css('ul.projectGroups li div h3 a').attr('href')

    "#{site_url}#{href}"
  end

  # The Extension is not in the url, so we force it
  # Otherwise the extraction will fail
  def archive_extension(url)
    '.zip'
  end
end
