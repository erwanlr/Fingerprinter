
# Django CMS
class DjangoCms < Fingerprinter
  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://github.com/divio/django-cms/releases').body)

    loop do
      page.css('h3 a span.tag-name').each do |node|
        version = node.text.strip

        next unless version =~ /\A[0-9\.]+\z/ # Only stable versions

        versions[version] = "https://github.com/divio/django-cms/archive/#{version}.zip"
      end

      page = next_page(page)
      break unless page
    end

    versions
  end

  # @return [ Nokogiri::HTML, nil ] The next download page if any, or nil
  def next_page(current_page)
    link = current_page.search('div.pagination a:nth-child(2)').first

    link ? Nokogiri::HTML(Typhoeus.get(link['href'].strip).body) : nil
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'cms'), dest)
  end

  def ignore_pattern
    /\A*.(py|pyc|html|po|mo)\z/i
  end
end
