
# Drupal
class Drupal < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    base_url = 'https://www.drupal.org/node/3060/release?&page=%i'
    page_id  = 0
    versions = {}

    loop do
      page = Nokogiri::HTML(Typhoeus.get(format(base_url, page_id), headers: { 'User-Agent' => 'cURL' }).body)

      page.css('span.file a').each do |node|
        version = node.text.strip[/\Adrupal-([0-9.]+).tar.gz\z/i, 1]

        if version
          versions[version] = "http://ftp.drupal.org/files/projects/#{node.text.strip}"
        end
      end

      break if page.css('li.pager-next').empty?
      page_id += 1
    end

    versions
  end
end
