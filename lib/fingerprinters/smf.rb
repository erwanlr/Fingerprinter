# frozen_string_literal: true

# Simple Machines Forum
class Smf < Fingerprinter
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}
    res      = Typhoeus.get('https://download.simplemachines.org/?archive')

    Nokogiri::HTML(res.body).css('ul.langlist li a').each do |option|
      version = option.text.strip[/\A([0-9.]+)\z/, 1]

      # Despite being listed, the 1.0.12 can not be downloaded: http://download.simplemachines.org/?archive;version=30
      next if version == '1.0.12' || version.nil?

      versions[version] = download_url(version)
    end

    versions
  end

  def download_url(version)
    v = version.gsub(/\.0\z/, '').tr('.', '-')

    "https://download.simplemachines.org/index.php?thanks;filename=smf_#{v}_install.zip"
  end

  # @param [ String ] archive_url
  # @param [ String ] dest
  def download_archive(archive_url, dest)
    # The page to download the archive needs to be accessed first as DDL is forbidden it seems
    # Then cookies from the response are required to download the .zip
    # If those two conditions are not meet, the error message below will be displayed in the response
    # 'Sorry but you can not directly download an archived file without first going through the Simple Machines website'
    res          = Typhoeus.get(archive_url)
    cookies      = [*res.headers['Set-Cookie']].map { |s| s.split(';')[0] }.join('; ')
    download_url = Nokogiri::HTML(res.body).css('div#secondarybody iframe').first['src'].to_s

    `wget -q -np -O #{dest.shellescape} --header='Cookie: #{cookies}' #{download_url.shellescape} > /dev/null`

    check_downloaded_file(dest)
  end
end
