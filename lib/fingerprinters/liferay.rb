
# LifeRay (http://sourceforge.net/projects/lportal/ & https://www.liferay.com/)
class Liferay < Fingerprinter
  include Experimental
  include IgnorePattern::JAVA

  def root_url
    'http://sourceforge.net/projects/lportal/files/Liferay%20Portal/'
  end

  def download_url(version, filename)
    "http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/#{URI.encode(version)}/#{URI.encode(filename)}"
  end

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(root_url).body)

    page.css('a.name').each do |link|
      version = link.text.strip

      next if version =~ /\A[0-9.]+ ?(?:RC|M|B)[0-9]?\z/i # Only keep the stables

      version_url = "#{root_url}#{URI.encode(version)}/"

      Nokogiri::HTML(Typhoeus.get(version_url).body).css('a.name').each do |node|
        file = node.text.strip

        # TODO: Merge those two into one regex
        next if file =~ /jre|jdk/i
        next unless file =~ /tomcat\-.*\.zip\z/i

        versions[version.gsub(/\s+/, '-')] = download_url(version, file)
        # p "#{version} => #{download_url(version, file)}"
        break
      end
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    Dir[File.join(dest, '**/')].each do |entry|
      next unless entry =~ /webapps/i
      return rebase(File.join(entry, 'ROOT'), dest)
    end

    fail "Unable to locate webapps/ROOT folder in #{dest}"
  end
end
