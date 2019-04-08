# frozen_string_literal: true

# Umbraco
class Umbraco < Fingerprinter
  include IgnorePattern::ASP

  def site_url
    'https://our.umbraco.com'
  end

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get("#{site_url}/download/releases").body)

    page.css('div h5 a').each do |node|
      version = node.text.strip

      next unless version =~ /\A[0-9\.]+\z/

      # rescue next is to skip releases w/o proper download link,
      # ie those removed because of critial issues like https://our.umbraco.org/contribute/releases/755/
      # Todo: find a better way to handle them
      versions[version] = begin
                            download_link("#{site_url}#{node.attr('href')}")
                          rescue StandardError
                            next
                          end
    end

    versions
  end

  protected

  def download_link(url)
    href = Nokogiri::HTML(Typhoeus.get(url).body).css('div.get-release div.release h3 a').attr('href')

    "#{site_url}#{href}"
  end

  # The Extension is not in the url, so we force it
  # Otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end
end
