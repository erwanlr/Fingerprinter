# frozen_string_literal: true

# Prestashop
class Prestashop < Fingerprinter
  include IgnorePattern::PHP

  def download_page_uri
    @download_page_uri ||= Addressable::URI.parse('https://www.prestashop.com/en/previous-versions')
  end

  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get(download_page_uri.to_s).body)

    page.css('div.views-field-field-release-file a').each do |link|
      href = link['href'].strip

      next unless href =~ /prestashop_([0-9-]+)\-zip/ # Only stable releases

      version = Regexp.last_match[1].tr('-', '.')

      versions[version] = download_page_uri.join(href).to_s
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    FileUtils.rm(File.join(dest, 'Install_PrestaShop.html'), force: true)

    sub_dir = Dir[File.join(dest, '*/')].first

    rebase(sub_dir, dest) if sub_dir =~ /\A#{dest}prestashop/i
  end

  # The Extension is not in the url, so we force it
  # Otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end
end
