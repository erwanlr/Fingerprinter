# frozen_string_literal: true

# WordPress Plugin
class WordpressPlugin < Fingerprinter
  include IgnorePattern::PHP

  VERSION_PATTERN = /\A[\d][\da-z\.\-]*\z/i.freeze

  def initialize(options = {})
    # Create additional required dirs if needed
    [DB_DIR, '/tmp'].each { |dir| FileUtils.mkdir_p(File.join(dir, 'wordpress_plugin')) }

    super(options)
  end

  def app_name
    "wordpress_plugin/#{item_slug}"
  end

  def db_dir
    File.join(DB_DIR, 'wordpress_plugin').to_s
  end

  def item_slug
    @options[:app_params]
  end

  def api_url
    format(
      'https://api.wordpress.org/plugins/info/1.1/?action=plugin_information&request[slug]=%s',
      item_slug
    )
  end

  def item_data
    @item_data ||= JSON.parse(Typhoeus.get(api_url, timeout: 20).body)
  end

  # returns a list of versions to ignore due to 404 no existent zips
  def ignore_list
    @ignore_list ||= JSON.parse(File.read(File.join(db_dir, '.ignore.json')))[item_slug] || []
  end

  def downloadable_versions
    versions = {}

    raise 'No data from WP API about this item (probably removed or disabled)' unless item_data
    raise item_data['error'] if item_data['error']

    # When empty, the 'versions' field is an array, but is a hash otherwise
    # Hence the .to_h
    { item_data['version'] => item_data['download_link'] }.merge(item_data['versions'].to_h).each do |version, download_link|
      cleaned = clean_version(version.to_s.dup)

      next if cleaned !~ VERSION_PATTERN || ignore_list.include?(cleaned)

      versions[cleaned] = download_link.gsub(/[\r\n]/, '')
    end

    versions
  end

  # Some version can be malformed, like 'v1.2.0', '.0.2.3', '0.2 Beta'
  # So we try to fix them before adding them
  def clean_version(version)
    version.gsub!(/\A(?:version|v)\s*/i, '') # deletes leading v or version, eg: 'v1.2.3', 'Version 1.2'
    version.gsub!(/[\r\n]/, '') # deletes new lines chars
    version.gsub!(/\s+/, '-') # replaces all spaces by '-'
    version.gsub!(/[\.]{2,}/, '.') # replaces more than one consecutive dots by one dot, eg: '0..2.1'

    version = "0#{version}" if version[0] == '.' # adds leading 0 if first char is a dot, eg: '.2.3'

    version
  end

  # @param [ String ] archive_url
  # @param [ String ] dest
  def download_archive(archive_url, dest)
    # Due to some plugins being messed up, including all previous versions in some of their
    # zip files, leading to huge zips (seen some 1/2/3GB ones), zips larger than 100MB will
    # be ignored, and a download error will be raised
    `curl --max-filesize 100000000 -s -o #{dest.shellescape} #{archive_url.shellescape} > /dev/null`

    check_downloaded_file(dest)
  end
end
