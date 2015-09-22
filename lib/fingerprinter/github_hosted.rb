
class Fingerprinter
  # Provides some methods to retrieve the release' versions and links
  # of a soft hosted on GitHub
  module GithubHosted
    # @param [ String ] repository
    # @param [ Regexp ] version_pattern
    #
    # @yield version, release_download_url
    # @return [ Hash ] version => release_download_url
    def github_releases(repository, version_pattern = /\A[0-9\.]+\z/)
      versions = {}
      page     = Nokogiri::HTML(Typhoeus.get(release_page_url(repository)).body)

      loop do
        page.css('h1.release-title a, h3 a span.tag-name').each do |node|
          version = node.text.strip

          next unless version =~ version_pattern

          versions[version] = release_download_url(repository, version)

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

    # @return [ String ]
    def release_download_url(repository, version)
      format('https://github.com/%s/archive/%s.zip', repository, version)
    end

    # @return [ Nokogiri::HTML, nil ] The next release page if any, or nil
    def next_release_page(current_page)
      link = current_page.search('div.pagination a:nth-child(2)').first

      link ? Nokogiri::HTML(Typhoeus.get(link['href'].strip).body) : nil
    end
  end
end
