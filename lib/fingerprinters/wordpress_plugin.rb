# WordPress Plugin
class WordpressPlugin < Fingerprinter
  include IgnorePattern::PHP

  VERSION_PATTERN = /\A[0-9\.\-]+[a-z]*\z/i

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

    # When empty, the 'versions' field is an array, but is a hash otherwise
    # Hence the .to_h
    { item_data['version'] => item_data['download_link'] }.merge(item_data['versions'].to_h).each do |version, download_link|
      # Some version can be malformed, like 'v1.2.0', '.0.2.3', '0.2 Beta'
      # So we try to fix them before adding them

      version = version.to_s.tr(' ', '\-')

      case version[0]
      when '.'
        version = "0#{version}"
      when 'v'
        version = version[1..-1]
      end

      next if version !~ VERSION_PATTERN || ignore_list.include?(version)

      versions[version] = download_link
    end

    versions
  end
end
