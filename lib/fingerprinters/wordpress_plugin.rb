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

  def downloadable_versions
    versions = {}

    raise 'No data from WP API about this plugin (probably removed or disabled)' if item_data.nil?

    latest_version = item_data['version']

    # Some version from the 'version' field can be malformed, like 'v1.2.0' and '.0.2.3'
    # So we try to fix them before adding them
    case latest_version[0]
    when '.'
      latest_version = "0#{latest_version}"
    when 'v'
      latest_version = latest_version[1..-1]
    end

    versions[latest_version] = item_data['download_link'] if latest_version =~ VERSION_PATTERN

    item_data['versions'].each do |version, download_link|
      next unless version =~ VERSION_PATTERN

      versions[version] = download_link
    end

    versions
  end
end
