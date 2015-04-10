
# Prestashop
class Prestashop < Fingerprinter
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get('https://www.prestashop.com/en/versions-developpeurs').body)

    page.css('a.btn-more').each do |link|
      href = link['href'].strip

      if href
        version = href[/prestashop_([0-9.]+)\.zip$/, 1]
        versions[version] = href
      end
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    FileUtils.rm(File.join(dest, 'Install_PrestaShop.html'), force: true)

    sub_dir = Dir[File.join(dest, '*/')].first

    rebase(sub_dir, dest) if sub_dir =~ /\A#{dest}prestashop/i
  end
end
