# frozen_string_literal: true

# FCKeditor
# Seems Like it's now discontinued as it returns a 403 from SourceForge
class Fckeditor < Fingerprinter
  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://sourceforge.net/projects/fckeditor/files/FCKeditor/', cookie: 'FreedomCookie=true').body)

    page.css('a.name').each do |link|
      version = link.text.strip
      versions[version] = "https://downloads.sourceforge.net/project/fckeditor/FCKeditor/#{version}/FCKeditor_#{version}.zip" if version =~ /\A[0-9\.]+\z/ # Only Stables
    end

    versions
  end

  def ignore_pattern
    /\A*.(php|aspx|cfm|asp|cfc|lasso|pl|py)\z/
  end
end
