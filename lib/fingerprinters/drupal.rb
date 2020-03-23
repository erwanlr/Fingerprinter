# frozen_string_literal: true

# Drupal
class Drupal < Fingerprinter
  include IgnorePattern::PHP

  # There is also a github repo, at https://github.com/drupal/core
  def downloadable_versions
    base_url = 'https://www.drupal.org/node/3060/release?&page=%i'
    page_id  = 0
    versions = {}

    loop do
      page = Nokogiri::HTML(Typhoeus.get(format(base_url, page_id),
                                         headers: { 'User-Agent' => 'curl/7.54.0' }).body)

      page.css('div.field-item a').each do |node|
        version = node.text.strip[/\A([\d.]+)\z/i, 1]

        versions[version] = "https://ftp.drupal.org/files/projects/drupal-#{version}.tar.gz" if version
      end

      break if page.css('li.pager-next').empty?

      page_id += 1
    end

    versions
  end
end
