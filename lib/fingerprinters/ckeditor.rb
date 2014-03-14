
# CKEditor
class Ckeditor < Fingerprinter
  include Experimental

  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get('http://ckeditor.com/download/releases').body)

    page.css('div p a').each do |link|
      version = link.attr('href').strip[/ckeditor_([0-9.]+)(?:_standard)?.zip$/, 1]

      versions[version] = link.attr('href') if version
    end

    versions
  end
end
