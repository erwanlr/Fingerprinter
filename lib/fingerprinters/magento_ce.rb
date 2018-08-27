
# Magento Community Edition
class MagentoCe < Fingerprinter
  include Experimental
  include IgnorePattern::PHP

  def download_page
    'https://magento.com/tech-resources/download'
  end

  # Valid session is required
  def cookie
    # 'frontend=aaa'
    nil
  end

  def downloadable_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(download_page).body)

    page.css('div.release-download div.col-sm-12 select').each do |select|
      next unless select['id'].strip =~ /\Acat_([0-9]+)_files\z/i

      cat_id = Regexp.last_match[1]

      select.css('option').each do |option|
        next unless option.text.strip =~ /\A(?:Magento (?:Community Edition|Open Source) |magento\-)([0-9\.]+)\.zip/i

        file_id = option['value'].strip

        versions[Regexp.last_match[1]] = download_url(file_id, cat_id)
      end
    end

    versions
  end

  # @return [ String ]
  def download_url(file_id, cat_id)
    format(
      'https://magento.com/tech-resources/downloads/magento/downloadFile/file_id/%i/file_category/%i/store_id/1/form_key/',
      file_id,
      cat_id
    )
  end

  # @param [ String ] archive_url
  # @param [ String ] dest
  def download_archive(archive_url, dest)
    # Adds the formKey to the download URL
    archive_url += form_key

    `wget -q -np -O #{dest.shellescape} --header='Cookie: #{cookie}' #{archive_url.shellescape} > /dev/null`

    check_downloaded_file(dest)
  end

  # @param [ Nokogiri::HTML ] page
  #
  # @return [ String, nil]
  def form_key
    unless cookie
      raise 'A valid session cookie is required to donwload the version.' \
           ' Please supply it in lib/fingerprinters/magento_ce.rb#cookie'
    end

    Nokogiri::HTML(Typhoeus.get(download_page, cookie: cookie).body).css('script').each do |script_tag|
      return Regexp.last_match[1] if script_tag.text.strip =~ /formKey = '([a-zA-Z0-9]+)';/
    end

    raise 'Unable to get the formKey'
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # Deletes directories that can not be accessible due to .htaccess
    %w[app dev includes lib update phpserver shell var vendor].each do |dir|
      FileUtils.rm_rf(File.join(dest, dir), secure: true)
    end
  end

  # Override to force the extension
  # Otherwise the extraction will fail
  def archive_extension(_url)
    '.zip'
  end
end
