# frozen_string_literal: true

class Fingerprinter
  # Provides some methods to retrieve the release' versions and links
  # of a soft hosted on GitHub
  module GithubHosted
    # @return [ Addressable::URI ]
    def github_uri
      @github_uri ||= Addressable::URI.parse('https://github.com')
    end

    # @param [ String ] repository
    # @param [ Regexp ] version_pattern Pattern to capture the version
    #
    # @yield version, release_download_url
    # @return [ Hash ] version => release_download_url
    def github_releases(repository, version_pattern = %r{/(?:archive/v?(?<v>[\d\.]+)|download/v?(?<v>[\d\.]+)/[^\s]+)\.zip\z}i)
      versions = {}
      page     = Nokogiri::HTML(Typhoeus.get(release_page_url(repository)).body)

      loop do
        page.css('ul a, div.Box--condensed a').each do |node|
          href    = node['href']
          version = href[version_pattern, :v]

          next unless version

          versions[version] = github_uri.join(href).to_s

          yield version, versions[version] if block_given?
        end

        page = next_release_page(page)
        break unless page
      end

      versions
    end

    # @return [ String ]
    def release_page_url(repository)
      format('https://github.com/%s/releases', repository)
    end

    # @return [ Nokogiri::HTML, nil ] The next release page if any, or nil
    def next_release_page(current_page)
      link = current_page.search('div.pagination a:nth-child(2)').first

      link ? Nokogiri::HTML(Typhoeus.get(link['href'].strip).body) : nil
    end
  end
end
