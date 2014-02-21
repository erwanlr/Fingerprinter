
# FCKeditor
class Fckeditor < Fingerprinter
  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('http://sourceforge.net/projects/fckeditor/files/FCKeditor/').body)

    page.css('a.name').each do |link|
      version = link.text.strip
      if version =~ /\A[0-9\.]+\z/ # Only Stables
        versions[version] = "http://downloads.sourceforge.net/project/fckeditor/FCKeditor/#{version}/FCKeditor_#{version}.zip"
      end
    end

    versions
  end

  def ignore_pattern
    /\A*.(php|aspx|cfm|asp|cfc|lasso|pl|py)\z/
  end
end
