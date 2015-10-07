
# Umbraco
class Umbraco < Fingerprinter
  include IgnorePattern::ASP

  def site_url
    'https://our.umbraco.org'
  end

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get("#{site_url}/contribute/releases").body)

    page.css('div h5 a').each do |node|
      version = node.text.strip

      if version =~ /\A[0-9\.]+\z/
        versions[version] = download_link("#{site_url}#{node.attr('href')}")
      end
    end

    versions
  end

  protected

  def download_link(url)
    href = Nokogiri::HTML(Typhoeus.get(url).body).css('div[class~="get-release"] div[class~="release"] h3 a').attr('href')

    "#{site_url}#{href}"
  end

  # The Extension is not in the url, so we force it
  # Otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end
end
