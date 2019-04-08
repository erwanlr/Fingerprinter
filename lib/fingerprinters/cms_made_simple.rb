# frozen_string_literal: true

# CMS Made Simple
class CmsMadeSimple < Fingerprinter
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    page = Nokogiri::HTML(Typhoeus.get('http://dev.cmsmadesimple.org/project/files/6').body)

    page.css('span.rVersions a').each do |link|
      version = link.text.strip[/\Acmsmadesimple-([0-9.]+)(?:-full)?\.tar\.gz\z/, 1]

      versions[version] = link.attr('href') if version
    end

    versions
  end
end
