# frozen_string_literal: true

# LifeRay (http://sourceforge.net/projects/lportal/ & https://www.liferay.com/)
class Liferay < Fingerprinter
  def root_url
    'https://sourceforge.net/projects/lportal/files/Liferay%20Portal/'
  end

  def download_url(version, filename)
    "https://downloads.sourceforge.net/project/lportal/Liferay%20Portal/#{Addressable::URI.encode(version)}/#{Addressable::URI.encode(filename)}"
  end

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(root_url, cookie: 'FreedomCookie=true').body)

    page.css('span.name').each do |span|
      version = span.text.strip

      next if version =~ /\A[0-9.]+ ?(?:A|B|M|RC)[0-9]?\z/i # Only keep the stables

      version_url = "#{root_url}#{Addressable::URI.encode(version)}/"

      Nokogiri::HTML(Typhoeus.get(version_url, cookie: 'FreedomCookie=true').body).css('span.name').each do |node|
        file = node.text.strip

        # TODO: Merge those two into one regex
        next if file =~ /jre|jdk/i
        next unless file =~ /tomcat\-.*\.zip\z/i

        versions[version.gsub(/\s+/, '-')] = download_url(version, file)
        break
      end
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    Dir[File.join(dest, '**/')].each do |entry|
      [%r{webapps\/ROOT}i, /liferay\-portal\.war/, /ROOT\.war/i].each do |pattern|
        return rebase(entry, dest) if entry =~ pattern
      end
    end

    # Some versions (i.e <= 4.3.0 have a different web folder and have to be added manually)
    raise "Unable to locate web folder in #{dest}"
  end

  def ignore_pattern
    %r{\A(.*(web\-inf|ckeditor/plugins).*|.*.(jspf?|jar|class|war|xsd|dtd))\z}i
  end
end
