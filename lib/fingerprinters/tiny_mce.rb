
# Tiny MCE
class Tinymce < Fingerprinter
  def downloadable_versions
    Hash[moxiecode_versions.merge(github_versions).to_a.sort.reverse]
  end

  # Versions from MoxieCode (latest to 3.5.9)
  def moxiecode_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://github.com/tinymce/tinymce/releases').body)

    page.css('span.tag-name').each do |node|
      version = node.text.strip

      if version =~ /\A[0-9\.]+\z/
        versions[version] = "http://download.moxiecode.com/tinymce/tinymce_#{version}.zip"
        break if Gem::Version.new(version) < Gem::Version.new('3.5.9')
      end
    end
    versions
  end

  # Versions from GitHub (< 3.5.9)
  def github_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://github.com/tinymce/tinymce/downloads').body)

    page.css('h4 a').each do |node|
      version = node.text.strip[/\Atinymce_([0-9.]+).zip\z/, 1]

      if version
        versions[version] = "https://github.com/downloads/tinymce/tinymce/tinymce_#{version}.zip"
      end
    end
    versions
  end
end
