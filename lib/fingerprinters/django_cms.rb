
# Django CMS
class DjangoCms < Fingerprinter
  include Experimental

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://github.com/divio/django-cms/releases').body)

    page.css('h3 a span.tag-name').each do |node|
      version = node.text.strip

      next unless version =~ /\A[0-9\.]+\z/ # Only stable versions

      versions[version] = "https://github.com/divio/django-cms/archive/#{version}.zip"
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    rebase(File.join(dest, 'cms'), dest)
  end

  def ignore_pattern
    /\A*.(py|pyc|html|po|mo)\z/i
  end
end
