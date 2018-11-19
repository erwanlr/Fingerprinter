# Drupal
class Drupal < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    base_url = 'https://www.drupal.org/node/3060/release?&page=%i'
    page_id  = 0
    versions = {}

    loop do
      page = Nokogiri::HTML(Typhoeus.get(format(base_url, page_id),
                                         headers: { 'User-Agent' => 'curl/7.54.0' }).body)

      page.css('span.file a').each do |node|
        version = node.text.strip[/\Adrupal\-([\d.]+)\.tar\.gz\z/i, 1]

        versions[version] = "https://ftp.drupal.org/files/projects/#{node.text.strip}" if version
      end

      break if page.css('li.pager-next').empty?

      page_id += 1
    end

    versions
  end
end
